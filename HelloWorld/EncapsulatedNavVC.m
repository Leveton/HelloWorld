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
    //[[self view] setBackgroundColor:[UIColor redColor]];
    //[[self view] setAlpha:0.5f];
    //[[[self view] layer] setOpacity:0.0f];
    [[self view] setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.6]];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"subviews");
    CGRect containerFrame = [[self containerView] frame];
    containerFrame.size.width = 500.0f;
    containerFrame.size.height = 500.0f;
    containerFrame.origin.x = [self horizontallyCenteredFrameForChildFrame:containerFrame].origin.x;
    containerFrame.origin.y = [self verticallyCenteredFrameForChildFrame:containerFrame].origin.y;
    [[self containerView] setFrame:containerFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[self view] setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.6]];
    [[self containerView] addSubview:[self navController]];
}

- (UIView *)containerView{
    if (!_containerView){
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [_containerView setBackgroundColor:[UIColor blueColor]];
        [_containerView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_containerView addGestureRecognizer:tap];
        [[_containerView layer] setCornerRadius:10.0f];
        [[self view] addSubview:_containerView];
        return _containerView;
    }
    return _containerView;
}

- (UIViewController *)viewController{
    if (!_viewController){
        _viewController = [[UIViewController alloc] init];
        [[_viewController view] setBackgroundColor:[UIColor yellowColor]];
        return _viewController;
    }
    return _viewController;
}

- (UINavigationController *)navigationController{
    if (!_navController){
        _navController = [[UINavigationController alloc]initWithRootViewController:[self viewController]];
    }
    return _navController;
}


#pragma mark - selectors

- (CGRect)horizontallyCenteredFrameForChildFrame:(CGRect)childRect{
    CGRect viewBounds = [self.view bounds];
    CGFloat listMinX = CGRectGetMidX(viewBounds) - (CGRectGetWidth(childRect)/2);
    CGRect newChildFrame = CGRectMake(listMinX,
                                      CGRectGetMinY(childRect),
                                      CGRectGetWidth(childRect),
                                      CGRectGetHeight(childRect));
    return CGRectIntegral(newChildFrame);
}

- (CGRect)verticallyCenteredFrameForChildFrame:(CGRect)childRect
{
    CGRect myBounds = [self.view bounds];
    childRect.origin.y = (CGRectGetHeight(myBounds)/2) - (CGRectGetHeight(childRect)/2);
    return childRect;
}

- (void)didTap:(id)sender{
    NSLog(@"did tap");
    [[self view] setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.6]];
}

@end
