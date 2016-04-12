//
//  PresentWithRadiusVC.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "PresentWithRadiusVC.h"

@interface PresentWithRadiusVC ()
@property (nonatomic, strong) UIBarButtonItem *leftButton;
@end

@implementation PresentWithRadiusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setLeftBarButtonItem:[self leftButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(didTapBack:)];
        
        return _leftButton;
    }
    return _leftButton;
}

- (void)didTapBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end