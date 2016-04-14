//
//  MELSuperCropView.h
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MELSuperCropDelegate;

@interface MELSuperCropView : UIView
@property (nonatomic, weak) id <MELSuperCropDelegate> delegate;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *croppedImage;
@property (nonatomic, assign, readonly) CGRect  cropFrame;
@property (nonatomic, assign, readonly) CGSize  cropSize;

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize;

- (void)setImage:(UIImage *)image;
- (void)setCropSize:(CGSize)cropSize;
- (void)setCropFrame:(CGRect)cropFrame;
@end

@protocol MELSuperCropDelegate <NSObject>

@end