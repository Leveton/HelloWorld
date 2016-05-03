//
//  MELSuperCropView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELSuperCropView.h"
#import "CropView.h"
#import "ZoomingImageScrollView.h"

#import <AVFoundation/AVFoundation.h>

@interface MELSuperCropView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView               *imageToCrop;
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


@property (nonatomic, assign) BOOL                      useScrollView;
@property (nonatomic, strong) ZoomingImageScrollView              *scrollView;
@property (nonatomic, strong) UIImageView               *scrollImageToCrop;
@end

@implementation MELSuperCropView

/* We still need the frame to get the origin */
- (id)initWithFrame:(CGRect)frame cropSize:(CGSize)cropSize maximumRadius:(CGFloat)maximumRadius{
    self = [super initWithFrame:frame];
    if (self){
        
    _useScrollView = YES;
        NSLog(@"self clips: %ld", (long)self.clipsToBounds);
        [self setClipsToBounds:YES];
        
#warning if they make the radius smaller than the cropper, use the formula where the image is a 4th as large as the cropper and the radius is a 4th as large as the image.
        
        /* the view's size must be the size of the radius in order to respond to touch events */
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
        
        //        NSLog(@"max radius 0: %f", maximumRadius);
        //        /* make sure user didn't create a smaller max radius than crop size */
        //        if (maximumRadius < cropSize.width || maximumRadius < cropSize.height){
        //            CGFloat proportion;
        //            CGFloat newHeight;
        //            CGFloat newWidth;
        //
        //            if (cropSize.width > cropSize.height){
        //                proportion           = cropSize.width/cropSize.height;
        //                newHeight            = cropSize.height * (5.0f/4.0f);
        //                maximumRadius        = newHeight * proportion;
        //            }else{
        //                proportion           = cropSize.height/cropSize.width;
        //                newWidth             = cropSize.width * (5.0f/4.0f);
        //                maximumRadius        = newWidth * proportion;
        //            }
        //        }
        //
        //        NSLog(@"max radius 1: %f", maximumRadius);
        
        CGFloat widthDiff  = (maximumRadius < frame.size.width) ? frame.size.width : (maximumRadius - frame.size.width)/2;
        
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

- (UIImageView *)imageToCrop{
    if (!_imageToCrop){
        _imageToCrop = [[UIImageView alloc]initWithFrame:CGRectZero];
        //[_imageToCrop.layer setZPosition:3.0f];
        [_imageToCrop setUserInteractionEnabled:YES];
        [_imageToCrop addGestureRecognizer:[self pan]];
        [_imageToCrop addGestureRecognizer:[self pinch]];
        [_imageToCrop setBackgroundColor:[UIColor clearColor]];
        //[_imageToCrop setContentMode:UIViewContentModeScaleAspectFit];
        //[_imageToCrop setClipsToBounds:YES];
        if (!_useScrollView){
            [self addSubview:_imageToCrop];
        }
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


- (ZoomingImageScrollView *)scrollView{
    if (!_scrollView){
        _scrollView = [[ZoomingImageScrollView alloc] initWithFrame:CGRectZero];
        //[_scrollView setDelegate:self];
        [_scrollView setScrollEnabled:YES];
        //[_scrollView setMinimumZoomScale:1.0f];
        //[_scrollView setMaximumZoomScale:5.0f];
        NSLog(@"clips?: %ld", (long)_scrollView.clipsToBounds);
        
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        //_scrollView.bouncesZoom = NO;
        _scrollView.clipsToBounds = NO;
        
        [self addSubview:_scrollView];
        return _scrollView;
    }
    return _scrollView;
}

- (UIImageView *)scrollImageToCrop{
    if (!_scrollImageToCrop){
        _scrollImageToCrop = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_scrollImageToCrop setImage:[UIImage imageNamed:@"pan"]];
        [[self scrollView] addSubview:_scrollImageToCrop];
        return _scrollImageToCrop;
    }
    return _scrollImageToCrop;
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
    
    
    if (_useScrollView){
        CGRect scrollFrame = [[self scrollView]frame];
        scrollFrame.size.height = _cropView.frame.size.height + 20.0f;
        CGFloat ratio           = _image.size.width/_image.size.height;
        scrollFrame.size.width  = scrollFrame.size.height * ratio;
        scrollFrame.origin.y    = _cropView.frame.origin.y - 10.0f;
        NSLog(@"width of scroll: %f", scrollFrame.size.width);
        [[self scrollView] setFrame:scrollFrame];
        
        CGRect scrollImageFrame = [[self scrollImageToCrop] frame];
        scrollImageFrame.size   = scrollFrame.size;
        scrollImageFrame.origin.x   = 0.0f;
        scrollImageFrame.origin.y   = 0.0f;
        [[self scrollImageToCrop] setFrame:scrollImageFrame];
        
        [[self scrollView] setContentSize:CGSizeMake(scrollFrame.size.width + 200, 0)];
        [[self scrollView] setOriginalWidth:scrollFrame.size.width];
        [[self scrollView] setOriginalContentWidth:scrollFrame.size.width + 200];
    }
    
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
        
#warning change this to only check for out of bounds in ended, if its out of bounds, it snaps back to it's closest corner, don't worry about bounds as this isn't pinch
        
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
        
        bool disAllowedPinch = _allowPinchOutsideOfRadius ? (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height) : (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height || gestureWidth > _maximumPinch || gestureHeight > _maximumPinch);
        
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
    
    if (_useScrollView){
        return [self croppedImageWithImage:_copiedImage rect:[self currentCropRect]];
    }else{
        return [self croppedImageWithImage:_image rect:[self currentCropRect]];
    }
}

- (CGRect)currentCropRect{
    if (_useScrollView){
        CGRect cropRect = [_cropView convertRect:_cropView.bounds toView:_scrollImageToCrop];
        NSLog(@"crop size: %f %f", cropRect.size.width, cropRect.size.height);
        CGFloat ratio   = 1.0f;
        
#warning I think this needs to be the original image chosen from the user
#warning I think you should use this method instead of the arbitrary 5/4 ratio above
        ratio           = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(_copiedImage.size, _scrollImageToCrop.bounds)) / _image.size.width;
        NSLog(@"ratio: %f", ratio);
        CGRect rect     = CGRectMake(cropRect.origin.x / ratio,cropRect.origin.y / ratio,cropRect.size.width / ratio,cropRect.size.height / ratio);
        return rect;
    }else{
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
}

- (UIImage *)croppedImageWithImage:(UIImage *)image rect:(CGRect)rect{
    
    CGFloat scale = image.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(croppedImage);
    
    return newImage;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _scrollImageToCrop;
}

@end
