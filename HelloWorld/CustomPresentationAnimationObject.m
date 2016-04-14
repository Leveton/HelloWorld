//
//  CustomPresentationAnimationObject.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPresentationAnimationObject.h"

@interface CustomPresentationAnimationObject()<UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL isPresenting;
@end

@implementation CustomPresentationAnimationObject

- (id)initWithIsPresenting:(BOOL)isPresenting{
    self = [super init];
    if (self){
        _isPresenting = isPresenting;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
}

@end
