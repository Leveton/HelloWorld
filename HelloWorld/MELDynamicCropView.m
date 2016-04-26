//
//  MELSuperCropView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELDynamicCropView.h"
#import "CropView.h"

#import <AVFoundation/AVFoundation.h>

@interface MELDynamicCropView()
@property (nonatomic, strong) UIImageView               *imageToCrop;
@property (nonatomic, strong) UIView                    *gestureView;
@property (nonatomic, strong) CropView                  *cropView;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, strong) UIPanGestureRecognizer    *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer  *pinch;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, assign) CGFloat                   maximumPinch;
@property (nonatomic, assign) CGAffineTransform         originalTransform;
@end

@implementation MELDynamicCropView

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize maximumRadius:(CGFloat)maximumRadius{
    self = [super initWithFrame:frame];
    if (self){
        
#warning if you drag the image to the top edge, and then pinch smaller, it gets stuck
        /* the view's size must be the size of the radius in order to respond to touch events */
        CGFloat widthDiff  = (maximumRadius < frame.size.width) ? frame.size.width : (maximumRadius - frame.size.width)/2;
        //CGFloat heightDiff = (maximumRadius < frame.size.height) ? frame.size.height : (maximumRadius - frame.size.height)/2;
        
//        if (maximumRadius < frame.size.width){
//            widthDiff = frame.size.width;
//        }else{
//            widthDiff = (maximumRadius - frame.size.width)/2;
//        }
//        
//        if (maximumRadius < frame.size.height){
//            heightDiff = frame.size.height;
//        }else{
//            heightDiff = (maximumRadius - frame.size.height)/2;
//        }
        
        CGRect newFrame = frame;
        newFrame.size   = CGSizeMake(maximumRadius, maximumRadius);
        newFrame.origin = CGPointMake(frame.origin.x - widthDiff, frame.origin.y - widthDiff);
        [self setFrame:newFrame];
        
        [self setCropSize:cropSize];
        [self setMaximumRadius:maximumRadius];
        
        _maximumPinch = (cropSize.width + newFrame.size.width)/2;
        NSLog(@"max pinch: %f", _maximumPinch);
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

- (UIView *)gestureView{
    if (!_gestureView){
        _gestureView = [[UIView alloc]initWithFrame:CGRectZero];
        [_gestureView setUserInteractionEnabled:YES];
        [_gestureView addGestureRecognizer:[self pan]];
        [_gestureView addGestureRecognizer:[self pinch]];
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
    [[self gestureView] setFrame:[self frameForGestureViewWithImage:_image]];
    
    _originalTransform = _gestureView.transform;
    
    CGRect imageFrame = [[self imageToCrop] frame];
    imageFrame.size.width   = _gestureView.bounds.size.width;
    imageFrame.size.height  = _gestureView.bounds.size.height;
    [[self imageToCrop] setFrame:imageFrame];
    
//    NSLog(@"_gestureView.bounds.size.width: %f", _gestureView.bounds.size.width);
//    NSLog(@"_gestureView.bounds.size.height: %f", _gestureView.bounds.size.width);
//    NSLog(@"_gestureView.bounds.origin.x: %f", _gestureView.bounds.origin.x);
//    NSLog(@"_gestureView.bounds.origin.y: %f", _gestureView.bounds.origin.y);
//    
//    NSLog(@"_gestureView.frame.size.width: %f", _gestureView.frame.size.width);
//    NSLog(@"_gestureView.frame.size.height: %f", _gestureView.frame.size.height);
//    NSLog(@"_gestureView.frame.origin.x: %f", _gestureView.frame.origin.x);
//    NSLog(@"_gestureView.frame.origin.y: %f", _gestureView.frame.origin.y);
    
    [[self imageToCrop] setImage:_image];
    
    _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - _imageToCrop.bounds.size.width;
    _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - _imageToCrop.bounds.size.height;
}

- (void)setAllowPinchOutsideOfRadius:(BOOL)allowPinchOutsideOfRadius{
    _allowPinchOutsideOfRadius = allowPinchOutsideOfRadius;
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
    
    if (image.size.width >= image.size.height){
        /* make the height 5/4ths the size of the crop view */
        proportion            = image.size.width/image.size.height;
        newHeight             = _cropSize.height * (5.0f/4.0f);
        newWidth              = newHeight * proportion;
        
        /* handle edge case where the width we're about to assign is out of bounds */
        if (!_allowPinchOutsideOfRadius && newWidth > _maximumPinch){
            newWidth = _maximumPinch;
            newHeight = newWidth * (image.size.height/image.size.width);
            NSLog(@"reached width condition: %f %f", newWidth, newHeight);
        }
        
        
    }else{
        /* make the width 5/4ths the size of the crop view */
        proportion             = image.size.height/image.size.width;
        newWidth               = _cropSize.width * (5.0f/4.0f);
        newHeight              = newWidth * proportion;
        
        /* handle edge case where the width we're about to assign is out of bounds */
        if (!_allowPinchOutsideOfRadius && newHeight > _maximumPinch){
            newHeight = _maximumPinch;
            newWidth = newHeight * (image.size.width/image.size.height);
            NSLog(@"reached height condition: %f %f", newWidth, newHeight);
        }
    }
    
    CGRect  dynamicImageViewFrame = [[self gestureView] frame];
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
        bool outOfBounds = NO;
        
        NSLog(@"crop dims: %f %f %f %f %f %f", originX, originY, _cropViewXOffset, _cropViewYOffset, _minimumImageXOffset, _minimumImageYOffset);
        if (originX < _cropViewXOffset && originY < _cropViewYOffset && originX > _minimumImageXOffset && originY > _minimumImageYOffset){
            
        }else{
            NSLog(@"reached out of bounds");
            outOfBounds = YES;
        }
        
        CGFloat gestureWidth  = [recognizer view].frame.size.width;
        CGFloat gestureHeight = [recognizer view].frame.size.height;

        bool disAllowedPinch = _allowPinchOutsideOfRadius ? (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height) : (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height || gestureWidth > _maximumPinch || gestureHeight > _maximumPinch);
        
        if (outOfBounds || disAllowedPinch){
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [[self gestureView] setTransform:_originalTransform];
                                 [self setImage:_copiedImage];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }
}

- (UIImage *)croppedImage{
    return [self rotatedImageWithImage:_image transform:[self imageViewRotation] rect:[self currentCropRect]];
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
    
    //CGSize size           = image.size;
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    CGContextRef context  = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, image.size.width / 2, image.size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, image.size.width / -2, image.size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    
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
