//
//  CustomPresentationController.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "CustomPresentationController.h"

@interface CustomPresentationController()
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation CustomPresentationController

- (id)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (void)presentationTransitionWillBegin{
    NSLog(@"reached will begin");
    
    [[self dimmingView] setFrame:[self frameOfPresentedViewInContainerView]];
    [[self containerView] addSubview:[self dimmingView]];
    [[self containerView] addSubview:self.presentedView];
}

- (void)presentationTransitionDidEnd:(BOOL)completed{
    NSLog(@"reached transition did end %@", self.presentingViewController);
}

- (void)dismissalTransitionDidEnd{
    NSLog(@"reached did end");
}

- (CGRect)frameOfPresentedViewInContainerView{
    
    //CGRect frame = self.containerView.frame;
    //frame.size.width = 500.0f;
    //frame.size.height = 500.0f;
    return self.containerView.frame;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    [[self containerView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (UIView *)dimmingView{
    if (!_dimmingView){
        _dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        [_dimmingView setBackgroundColor:[UIColor blueColor]];
        [_dimmingView setAlpha:0.5f];
        return _dimmingView;
    }
    return _dimmingView;
}

@end
