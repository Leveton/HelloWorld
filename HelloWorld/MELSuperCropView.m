//
//  MELSuperCropView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELSuperCropView.h"
#import "CropView.h"

#import <AVFoundation/AVFoundation.h>

@interface MELSuperCropView()
@property (nonatomic, strong) UIImageView *imageToCrop;
@property (nonatomic, strong) UIView      *gestureView;
@property (nonatomic, strong) CropView    *cropView;
@property (nonatomic, assign) CGFloat     cropViewXOffset;
@property (nonatomic, assign) CGFloat     cropViewYOffset;
@property (nonatomic, assign) CGFloat     minimumImageXOffset;
@property (nonatomic, assign) CGFloat     minimumImageYOffset;
@end

@implementation MELSuperCropView

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize{
    self = [super initWithFrame:frame];
    if (self){
        [self setBackgroundColor:[UIColor redColor]];
        [self setCropSize:cropSize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

#pragma mark - getters

- (CropView *)cropView{
    if (!_cropView){
        _cropView = [[CropView alloc] initWithFrame:CGRectZero];
        [_cropView setBackgroundColor:[UIColor blueColor]];
        [[_cropView layer] setOpacity:0.2f];
        [[_cropView layer] setZPosition:1.0f];
        [self addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

- (UIView *)gestureView{
    if (!_gestureView){
        _gestureView = [[UIView alloc]initWithFrame:CGRectZero];
        //[_gestureView setBackgroundColor:[UIColor redColor]];
        [_gestureView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        [_gestureView addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
        [_gestureView addGestureRecognizer:pinch];
        [self addSubview:_gestureView];
        return _gestureView;
    }
    
    return _gestureView;
}

- (UIImageView *)imageToCrop{
    if (!_imageToCrop){
        _imageToCrop = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_imageToCrop.layer setZPosition:3.0f];
        [_imageToCrop setBackgroundColor:[UIColor clearColor]];
        [_imageToCrop setContentMode:UIViewContentModeScaleAspectFit];
        [_imageToCrop setClipsToBounds:YES];
        [[self gestureView] addSubview:_imageToCrop];
        return _imageToCrop;
    }
    return _imageToCrop;
}

- (CGRect)initialCropFrame{
    CGRect cropFrame   = CGRectZero;
    cropFrame.size     = _cropSize;
    cropFrame.origin.x = (CGRectGetWidth([self frame]) - _cropSize.width)/2;
    cropFrame.origin.y = (CGRectGetHeight([self frame]) - _cropSize.height)/2;
    return cropFrame;
}

#pragma mark - setters

- (void)setCropSize:(CGSize)cropSize{
    _cropSize = cropSize;
    NSLog(@"crop width: %f", _cropSize.width);
}

- (void)setCropFrame:(CGRect)cropFrame{
    _cropFrame = cropFrame;
    [[self cropView] setFrame:_cropFrame];
    _cropViewXOffset = cropFrame.origin.x;
    _cropViewYOffset = cropFrame.origin.y;
    NSLog(@"crop Y: %f", _cropViewYOffset);
}

- (void)setImage:(UIImage *)image{
    _image = image;
    NSLog(@"set imsge: %@", _image);
    
    [self setCropFrame:[self initialCropFrame]];
    [[self gestureView] setFrame:[self frameForGestureViewWithImage:_image]];
    
    CGRect frame = [[self gestureView] frame];
    frame.origin.x = self.frame.origin.x;
    frame.origin.y = self.frame.origin.y;
    [self setFrame:frame];
    
    CGRect imageFrame = [[self imageToCrop] frame];
    imageFrame.size.width   = _gestureView.bounds.size.width;
    imageFrame.size.height  = _gestureView.bounds.size.height;
    [[self imageToCrop] setFrame:imageFrame];
    
    [[self imageToCrop] setImage:_image];
    
    _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - _imageToCrop.bounds.size.width;
    _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - _imageToCrop.bounds.size.height;
    
}

#pragma mark - selectors

- (CGRect)frameForGestureViewWithImage:(UIImage *)image{
    
    CGFloat proportion;
    CGFloat newHeight;
    CGFloat newWidth;
    
    if (image.size.width >= image.size.height){
        /* make the height 5/4ths the size of the crop view */
        proportion            = image.size.width/image.size.height;
        newHeight             = _cropSize.height * (5.0f/4.0f);
        newWidth              = newHeight * proportion;
        
    }else{
        /* make the width 5/4ths the size of the crop view */
        proportion             = image.size.height/image.size.width;
        newWidth               = _cropSize.width * (5.0f/4.0f);
        newHeight              = newWidth * proportion;
    }
    
    CGRect  dynamicImageViewFrame = [[self gestureView] frame];
    dynamicImageViewFrame.size.width  = newWidth;
    dynamicImageViewFrame.size.height = newHeight;
    dynamicImageViewFrame.origin.x    = _cropViewXOffset -  (newWidth - _cropView.bounds.size.width)/2;
    dynamicImageViewFrame.origin.y    = _cropViewYOffset -  (newHeight - _cropView.bounds.size.height)/2;
    NSLog(@"floats: %f %f %f %f", _cropSize.width, _cropSize.height, _cropViewXOffset, _cropViewYOffset);
    return dynamicImageViewFrame;
}

- (void)didPan:(UIPanGestureRecognizer *)pan{
    NSLog(@"did pan");
    if (pan.state == UIGestureRecognizerStateChanged){
        
        CGRect imageFrame = [[pan view] frame];
        
        CGPoint translation = [pan translationInView:pan.view.superview];
        pan.view.center = CGPointMake(pan.view.center.x + translation.x,
                                      pan.view.center.y + translation.y);
        
        CGFloat originX = pan.view.frame.origin.x;
        CGFloat originY = pan.view.frame.origin.y;
        
        
        if (originX < _cropViewXOffset && originY < _cropViewYOffset && originX > _minimumImageXOffset && originY > _minimumImageYOffset){
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }else{
            [[pan view] setFrame:imageFrame];
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded){
        _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - pan.view.frame.size.width;
        _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - pan.view.frame.size.height;
    }
    
}

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer{
    NSLog(@"did pinch");
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (UIImage *)croppedImage{
    return [self rotatedImageWithImage:_image transform:self.imageViewRotation rect:[self currentCropRect]];
}

- (CGAffineTransform)imageViewRotation{
    return _imageToCrop.transform;
}

- (CGRect)currentCropRect{
    CGRect cropRect = [_cropView convertRect:_cropView.bounds toView:_gestureView];
    CGSize size     = _image.size;
    CGFloat ratio   = 1.0f;
    ratio           = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(_image.size, _gestureView.bounds)) / size.width;
    CGRect rect     = CGRectMake(cropRect.origin.x / ratio,cropRect.origin.y / ratio,cropRect.size.width / ratio,cropRect.size.height / ratio);
    return rect;
}

- (UIImage *)rotatedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform rect:(CGRect)rect{
    
    CGSize size           = image.size;
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,
                                           image.scale);
    CGContextRef context  = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGFloat scale = rotatedImage.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImage scale:image.scale orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    return newImage;
}


@end
