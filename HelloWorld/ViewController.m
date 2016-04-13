//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//




// https://www.cocoacontrols.com/controls/mzformsheetpresentationcontroller



#import "ViewController.h"
#import "PresentWithRadiusVC.h"
#import "EncapsulatedNavVC.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect buttonFrame = [[self button] frame];
    buttonFrame.size.height = 32.0f;
    buttonFrame.size.width = 300.0f;
    buttonFrame.origin.y = CGRectGetMaxY(labelFrame) + 10.0f;
    buttonFrame.origin.x = [self horizontallyCenteredFrameForChildFrame:buttonFrame].origin.x;
    [[self button] setFrame:buttonFrame];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Present View Controller"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIButton *)button{
    if (!_button){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"present vc" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setBackgroundColor:[UIColor redColor]];
        [[self view] addSubview:_button];
        return _button;
    }
    return _button;

}

- (void)didTapButton:(id)sender{
    PresentWithRadiusVC *vc = [[PresentWithRadiusVC alloc]init];
    [[vc view] setBackgroundColor:[UIColor redColor]];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [nav setModalPresentationStyle:UIModalPresentationPageSheet];
    //[nav setModalPresentationStyle:UIModalPresentationFormSheet];
    //[nav setModalPresentationStyle:UIModalPresentationCustom];
    //[nav setPreferredContentSize:CGSizeMake(600, 10000)];
    //[self presentViewController:nav animated:YES completion:nil];
    
    EncapsulatedNavVC *vc1 = [EncapsulatedNavVC new];
    [self presentViewController:vc1 animated:YES completion:nil];
}

- (CGRect)horizontallyCenteredFrameForChildFrame:(CGRect)childRect{
    CGRect viewBounds = [[self view] bounds];
    CGFloat listMinX = CGRectGetMidX(viewBounds) - (CGRectGetWidth(childRect)/2);
    CGRect newChildFrame = CGRectMake(listMinX,
                                      CGRectGetMinY(childRect),
                                      CGRectGetWidth(childRect),
                                      CGRectGetHeight(childRect));
    return CGRectIntegral(newChildFrame);
}

@end
