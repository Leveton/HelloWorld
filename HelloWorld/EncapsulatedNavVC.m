//
//  EncapsulatedNavVC.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "EncapsulatedNavVC.h"

@interface EncapsulatedNavVC ()
@property (nonatomic, strong) UIView                 *containerView;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UIViewController       *viewController;
@end

@implementation EncapsulatedNavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
