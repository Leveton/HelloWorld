//
//  ZoomingImageScrollView.h
//  HelloWorld
//
//  Created by Mike Leveton on 4/6/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomingImageScrollView : UIScrollView
@property (nonatomic) NSUInteger                        index;
@property (nonatomic, strong) UIImageView               *imageZoomView;
@property (nonatomic, strong, readonly) UIImage         *image;

- (void)setImage:(UIImage *)image;
@end
