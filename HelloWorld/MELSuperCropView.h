//
//  MELDynamicCropView.h
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MELSuperCropViewDelegate;

@interface MELSuperCropView : UIView
@property (nonatomic, weak) id <MELSuperCropViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIImage             *image;
@property (nonatomic, strong, readonly) UIImage             *croppedImage;
@property (nonatomic, strong, readonly) UIColor             *cropColor;
@property (nonatomic, assign, readonly) CGRect              cropFrame;
@property (nonatomic, assign, readonly) CGSize              cropSize;
@property (nonatomic, assign, readonly) CGFloat             cropAlpha;
@property (nonatomic, assign, readonly) CGFloat             maximumRadius;
@property (nonatomic, assign, readonly) BOOL                allowPinchOutsideOfRadius;

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize maximumRadius:(CGFloat)maximumRadius;

- (void)setImage:(UIImage *)image;
- (void)setCropColor:(UIColor *)cropColor;
- (void)setCropSize:(CGSize)cropSize;
- (void)setCropAlpha:(CGFloat)cropAlpha;
- (void)setMaximumRadius:(CGFloat)maximumRadius;
- (void)setCropFrame:(CGRect)cropFrame;
- (void)setAllowPinchOutsideOfRadius:(BOOL)allowPinchOutsideOfRadius;

@end

@protocol MELSuperCropViewDelegate <NSObject>

@end
