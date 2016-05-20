//
//  CoreDataManager.h
//  HelloWorld
//
//  Created by Mike Leveton on 5/20/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject
@property (strong, nonatomic) NSPersistentStoreCoordinator   *psc;
@property (strong, nonatomic) NSManagedObjectContext         *context;

+ (CoreDataManager *)sharedInstance;

- (NSManagedObjectContext *)createNewManagedObjectContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)itemArchivePath;
- (BOOL)saveChanges;
- (void)deleteAndRecreatePersistentStore;
@end
