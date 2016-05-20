//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
//#import "AppDelegate.h"
#import "Car.h"
#import "CoreDataManager.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *addressEntity  = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:context];
    Car *car0   = [[Car alloc] initWithEntity:addressEntity insertIntoManagedObjectContext:context];
    [car0 setDriver:@"mike"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"save error: %@", error);
    }else{
        NSLog(@"save 0 ok");
    }
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Core Data"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [[CoreDataManager sharedInstance] context];
}

@end
