//
//  MELCropView.h
//  HelloWorld
//
//  Created by Mike Leveton on 5/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MELCropViewDelegate;

@interface MELCropView : UIView
@property (nonatomic, weak) id <MELCropViewDelegate>        delegate;
@property (nonatomic, strong, readonly) UIImage             *image;
@property (nonatomic, strong, readonly) UIImage             *croppedImage;
@property (nonatomic, strong, readonly) UIColor             *cropColor;
@property (nonatomic, assign, readonly) CGRect              cropFrame;
@property (nonatomic, assign, readonly) CGSize              cropSize;
@property (nonatomic, assign, readonly) CGFloat             cropAlpha;

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize;

- (void)setImage:(UIImage *)image;
- (void)setCropColor:(UIColor *)cropColor;
- (void)setCropSize:(CGSize)cropSize;
- (void)setCropAlpha:(CGFloat)cropAlpha;
- (void)setCropFrame:(CGRect)cropFrame;

@end

@protocol MELCropViewDelegate <NSObject>

@end
