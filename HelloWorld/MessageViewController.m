//
//  MessageViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//


//this is the controller being presented

#import "MessageViewController.h"
#import "CustomPresentationController.h"
#import "CustomPresentationAnimationObject.h"

@interface MessageViewController ()<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@end

@implementation MessageViewController

- (id)init{
    self = [super init];
    if (self){
        NSLog(@"reached init");
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    
    if (presented == self) {
        return [[CustomPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if (dismissed == self) {
        //return CustomPresentationAnimationController(isPresenting: false)
        return [[CustomPresentationAnimationObject  alloc]initWithIsPresenting:NO];
        
    }
    else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    if (presented == self) {
        //return CustomPresentationAnimationController(isPresenting: false)
        return [[CustomPresentationAnimationObject  alloc]initWithIsPresenting:YES];
        
    }
    else {
        return nil;
    }
}

@end
