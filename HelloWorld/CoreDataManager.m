//
//  CoreDataManager.M
//  HelloWorld
//
//  Created by Mike Leveton on 5/20/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[CoreDataManager sharedinstance]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self initWithCoreDataSetup];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static CoreDataManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initPrivate];
    });
    
    return sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)createNewManagedObjectContext{
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]; //turn into class method that has a PSC
    [newContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return newContext;
}

- (void)initWithCoreDataSetup {
    //read in coredata model
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //where does the SQLite file go
    NSString *path = [self itemArchivePath];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSLog(@"StoreURL %@",storeURL);
    NSError *error = nil;
    
    if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    //create the managed object context
    _context = [self createNewManagedObjectContext];
    [_context setPersistentStoreCoordinator:_psc];
    
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
    ;
    //get the one and only doc from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.sqlite"];
}


- (BOOL)saveChanges {
    //returns success or failure
    if ([[self context] hasChanges]) {
        NSError *err = nil;
        BOOL successful = [_context save:&err];
        
        if (!successful) {
            
            NSLog(@"save not successful");
        }
        
        return successful;
    }else {
        return YES;
    }
}

- (void)deleteAndRecreatePersistentStore{
    [_context reset];
    NSPersistentStore *store = [[_psc persistentStores] lastObject];
    NSError *error;
    [_psc removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:[store URL] error:&error];
    
    _context = nil;
    _psc = nil;
    [self initWithCoreDataSetup];
}

@end
