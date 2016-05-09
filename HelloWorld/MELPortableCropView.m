//
//  MELSuperCropView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELPortableCropView.h"
#import "CropView.h"
#import "ZoomingImageScrollView.h"

#import <AVFoundation/AVFoundation.h>

@interface MELPortableCropView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView               *imageToCrop;
@property (nonatomic, strong) CropView                  *cropView;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, strong) UIPanGestureRecognizer    *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer  *pinch;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, assign) CGAffineTransform         originalTransform;

@end

@implementation MELPortableCropView

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize maximumRadius:(CGFloat)maximumRadius{
    self = [super initWithFrame:frame];
    if (self){
        
        NSLog(@"self clips: %ld", (long)self.clipsToBounds);
        [self setClipsToBounds:YES];
        
        
#warning if they make the radius smaller than the cropper, reverse the two sizes and make the image in-between.
        
        CGFloat widthDiff  = (maximumRadius < frame.size.width) ? frame.size.width : (maximumRadius - frame.size.width)/2;
        
        CGRect newFrame = frame;
        newFrame.size   = CGSizeMake(maximumRadius, maximumRadius);
        newFrame.origin = CGPointMake(frame.origin.x - widthDiff, frame.origin.y - widthDiff);
        [self setFrame:newFrame];
        
        [self setCropSize:cropSize];
        [self setMaximumRadius:maximumRadius];
        
    }
    return self;
}

#pragma mark - getters

- (CropView *)cropView{
    if (!_cropView){
        _cropView = [[CropView alloc] initWithFrame:CGRectZero];
        
        /* default crop color and opacity */
        [_cropView setBackgroundColor:[UIColor blueColor]];
        [[_cropView layer] setOpacity:0.2f];
        
        [[_cropView layer] setZPosition:1.0f];
        [self addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

- (UIImageView *)imageToCrop{
    if (!_imageToCrop){
        _imageToCrop = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_imageToCrop setUserInteractionEnabled:YES];
        [_imageToCrop addGestureRecognizer:[self pan]];
        [_imageToCrop addGestureRecognizer:[self pinch]];
        [_imageToCrop setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_imageToCrop];
        return _imageToCrop;
    }
    return _imageToCrop;
}

- (CGRect)centeredCropFrame{
    CGRect cropFrame   = CGRectZero;
    cropFrame.size     = _cropSize;
    cropFrame.origin.x = (CGRectGetWidth([self frame]) - _cropSize.width)/2;
    cropFrame.origin.y = (CGRectGetHeight([self frame]) - _cropSize.height)/2;
    return cropFrame;
}

- (UIPanGestureRecognizer *)pan{
    if (!_pan){
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
    }
    return _pan;
}

- (UIPinchGestureRecognizer *)pinch{
    if (!_pinch){
        _pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
    }
    return _pinch;
}

#pragma mark - setters

- (void)setMaximumRadius:(CGFloat)maximumRadius{
    _maximumRadius = maximumRadius;
}

- (void)setCropSize:(CGSize)cropSize{
    _cropSize = cropSize;
}

- (void)setCropFrame:(CGRect)cropFrame{
    _cropFrame = cropFrame;
    [[self cropView] setFrame:_cropFrame];
    _cropViewXOffset = cropFrame.origin.x;
    _cropViewYOffset = cropFrame.origin.y;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _copiedImage = [_image copy];
    
    
    [self setCropFrame:[self centeredCropFrame]];
    [[self imageToCrop] setFrame:[self frameForGestureViewWithImage:_image]];
    
    _originalTransform = _imageToCrop.transform;
    
    [[self imageToCrop] setImage:_image];
    
    _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - _imageToCrop.bounds.size.width;
    _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - _imageToCrop.bounds.size.height;
}

- (void)setCropAlpha:(CGFloat)cropAlpha{
    _cropAlpha = cropAlpha;
    [[[self cropView] layer] setOpacity:_cropAlpha];
}

- (void)setCropColor:(UIColor *)cropColor{
    _cropColor = cropColor;
    [[self cropView] setBackgroundColor:_cropColor];
}

#pragma mark - selectors

- (CGRect)frameForGestureViewWithImage:(UIImage *)image{
    
    CGFloat proportion;
    CGFloat newHeight;
    CGFloat newWidth;
    
    NSLog(@"image dims: %f %f", image.size.width, image.size.height);
    
#warning change this to make the image exactly halfway between the cropper and the max radius. use the CGRectFormula
    
    if (image.size.width >= image.size.height){
        
        /* make the height 5/4ths the size of the crop view */
        proportion            = image.size.width/image.size.height;
        newHeight             = _cropSize.height * (5.0f/4.0f);
        newWidth              = newHeight * proportion;
        
        
    }else{
        NSLog(@"image is portrait");
        /* make the width 5/4ths the size of the crop view */
        proportion             = image.size.height/image.size.width;
        newWidth               = _cropSize.width * (5.0f/4.0f);
        newHeight              = newWidth * proportion;
    }
    
    CGRect  dynamicImageViewFrame = [[self imageToCrop] frame];
    dynamicImageViewFrame.size.width  = newWidth;
    dynamicImageViewFrame.size.height = newHeight;
    dynamicImageViewFrame.origin.x    = _cropViewXOffset -  (newWidth - _cropView.bounds.size.width)/2;
    dynamicImageViewFrame.origin.y    = _cropViewYOffset -  (newHeight - _cropView.bounds.size.height)/2;
    
    NSLog(@"gesture dims: %f %f", dynamicImageViewFrame.size.width, dynamicImageViewFrame.size.height);
    
    return dynamicImageViewFrame;
}

- (void)didPan:(UIPanGestureRecognizer *)pan{
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
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    if ([recognizer state] == UIGestureRecognizerStateEnded){
        
        /* first check if the new x and y offsets are too far below or too far above the cropper, gesture will get stuck if you let this go */
        
#warning find the image y offset plus the height of the image and make sure it is greator than the y offset + height of the cropper. you may need to do this for the width as well
        CGFloat originX = recognizer.view.frame.origin.x;
        CGFloat originY = recognizer.view.frame.origin.y;
        CGFloat gestureMaxX    = originX + recognizer.view.frame.size.width;
        CGFloat gestureMaxY    = originY + recognizer.view.frame.size.height;
        CGFloat cropperMaxX    = _cropViewXOffset + _cropSize.width;
        CGFloat cropperMaxY    = _cropViewYOffset + _cropSize.height;
        bool outOfBounds       = NO;
        
        NSLog(@"crop dims: %f %f %f %f %f %f", originX, originY, _cropViewXOffset, _cropViewYOffset, _minimumImageXOffset, _minimumImageYOffset);
        NSLog(@"max dims: %f %f %f %f", gestureMaxX, gestureMaxY, cropperMaxX, cropperMaxY);
        
        if (cropperMaxX > gestureMaxX || cropperMaxY > gestureMaxY || originX > _cropViewXOffset || originY > _cropViewYOffset){
            outOfBounds = YES;
        }
        
        CGFloat gestureWidth  = [recognizer view].frame.size.width;
        CGFloat gestureHeight = [recognizer view].frame.size.height;
        
        bool disAllowedPinch = (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height);
        
        NSLog(@"bounds and pinch: %ld %ld", (long)outOfBounds, (long)disAllowedPinch);
        
        if (outOfBounds || disAllowedPinch){
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [[self imageToCrop] setTransform:_originalTransform];
                                 [self setImage:_copiedImage];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }else{
            _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width)  - recognizer.view.frame.size.width;
            _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - recognizer.view.frame.size.height;
        }
    }
}

#pragma mark - image methods

- (UIImage *)croppedImage{
    
    return [self croppedImageWithImage:_image rect:[self currentCropRect]];
}

- (CGRect)currentCropRect{
    /* this takes _cropView and puts it in _imageToCrop's coordinate space without moving it */
    CGRect cropRect = [_cropView convertRect:_cropView.bounds toView:_imageToCrop];
    NSLog(@"crop size: %f %f", cropRect.size.width, cropRect.size.height);
    CGFloat ratio   = 1.0f;
    
    /*changes the rect you give it to another rect with the aspect ratio that you want */
    ratio           = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(_image.size, _imageToCrop.bounds)) / _image.size.width;
    NSLog(@"ratio: %f", ratio);
    CGRect rect     = CGRectMake(cropRect.origin.x/ratio, cropRect.origin.y/ratio, cropRect.size.width/ratio, cropRect.size.height/ratio);
    return rect;
}

- (UIImage *)croppedImageWithImage:(UIImage *)image rect:(CGRect)rect{
    
    CGFloat scale = image.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(croppedImage);
    
    return newImage;
}

@end
