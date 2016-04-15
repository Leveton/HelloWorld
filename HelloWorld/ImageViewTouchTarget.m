//
//  ImageViewTouchTarget.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/15/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ImageViewTouchTarget.h"

@implementation ImageViewTouchTarget

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    CGFloat radius = 100.0;
//    CGRect frame = CGRectMake(-radius, -radius,
//                              self.frame.size.width + radius,
//                              self.frame.size.height + radius);
//    
//    if (CGRectContainsPoint(frame, point)) {
//        return self;
//    }
//    return nil;
    
    UIView *view = [super hitTest:point withEvent:event];
    NSLog(@"aFloat: %f %f %f %f", view.frame.size.width, view.frame.size.height, view.frame.origin.x, view.frame.origin.y);
    return view;
}

@end
