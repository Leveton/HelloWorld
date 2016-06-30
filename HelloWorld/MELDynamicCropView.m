//
//  MELDynamicCropView.m
//  MELDynamicCropView
//
//  Created by Mike Leveton on 5/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELDynamicCropView.h"

#import <AVFoundation/AVFoundation.h>


@interface MELDynamicCropView()
@property (nonatomic, strong) UIImageView               *imageToCrop;
@property (nonatomic, strong) UIView                    *cropView;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, strong) UIPanGestureRecognizer    *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer  *pinch;
@property (nonatomic, assign) CGSize                    cropSize;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, assign) CGAffineTransform         originalTransform;

@end

@implementation MELDynamicCropView

- (id)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame{
    self = [super initWithFrame:frame];
    if (self){
        [self setClipsToBounds:YES];
        CGSize cropSize = cropFrame.size;
        
        [self setCropSize:cropSize];
    }
    
    [self setCropFrame:cropFrame];
    return self;
}

#pragma mark - getters

- (UIView *)cropView{
    if (!_cropView){
        _cropView = [[UIView alloc] initWithFrame:_cropFrame];
        
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

- (CGFloat)distanceFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB{
    return sqrt((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
}

- (CGPoint)orientationCenteredWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x       = _cropViewXOffset -  (size.width - _cropView.bounds.size.width)/2;
    point.y       = _cropViewYOffset -  (size.height - _cropView.bounds.size.height)/2;
    return point;
}

- (CGPoint)orientationTopLeftWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = _cropViewXOffset;
    point.y    = _cropViewYOffset;
    return point;
}

- (CGPoint)orientationTopRightWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = CGRectGetMaxX([_cropView frame]) - size.width;
    point.y    = _cropViewYOffset;
    return point;
}

- (CGPoint)orientationBottomLeftWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = _cropViewXOffset;
    point.y    = CGRectGetMaxY([_cropView frame]) - size.height;
    return point;
}

- (CGPoint)orientationBottomRightWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = CGRectGetMaxX([_cropView frame]) - size.width;
    point.y    = CGRectGetMaxY([_cropView frame]) - size.height;
    return point;
}


#pragma mark - setters

- (void)setCropSize:(CGSize)cropSize{
    _cropSize = cropSize;
}

- (void)setCropFrame:(CGRect)cropFrame{
    _cropFrame = cropFrame;
    
    CGSize cropSize = cropFrame.size;
    
    [self setCropSize:cropSize];
    
    [[self cropView] setFrame:_cropFrame];
    _cropViewXOffset = cropFrame.origin.x;
    _cropViewYOffset = cropFrame.origin.y;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _copiedImage = [_image copy];
    
    [[self imageToCrop] setFrame:self.frame];
    
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
    
    NSLog(@"recognizer.scale: %f %f %f", _imageToCrop.bounds.size.width, _imageToCrop.frame.origin.x, _imageToCrop.frame.origin.y);
    if (_imageToCrop.frame.size.width < 270.0f && [[self delegate] respondsToSelector:@selector(imageWasPinchedWithFrame:)]){
        
        [[self delegate] imageWasPinchedWithFrame:_imageToCrop.frame];
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded){
        
        /* first check if the new x and y offsets are too far below or too far above the cropper, gesture will get stuck if you let this go */
        
        CGFloat gestureOriginX = recognizer.view.frame.origin.x;
        CGFloat gestureOriginY = recognizer.view.frame.origin.y;
        CGFloat gestureMaxX    = gestureOriginX + recognizer.view.frame.size.width;
        CGFloat gestureMaxY    = gestureOriginY + recognizer.view.frame.size.height;
        CGFloat cropperMaxX    = _cropViewXOffset + _cropSize.width;
        CGFloat cropperMaxY    = _cropViewYOffset + _cropSize.height;
        //bool outOfBounds       = NO;
        
        bool outOfBounds       = (cropperMaxX > gestureMaxX || cropperMaxY > gestureMaxY || gestureOriginX > _cropViewXOffset || gestureOriginY > _cropViewYOffset);
        
        CGFloat gestureWidth   = [recognizer view].frame.size.width;
        CGFloat gestureHeight  = [recognizer view].frame.size.height;
        
        bool disAllowedPinch   = (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height);
        
        if (outOfBounds || disAllowedPinch){
            
            NSMutableArray *distanceArray = [NSMutableArray array];
            NSNumber *topLeft;
            NSNumber *topRight;
            NSNumber *bottomLeft;
            NSNumber *bottomRight;
            
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureOriginY))){
                topLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureOriginY) toPoint:CGPointMake(_cropViewXOffset, _cropViewYOffset)]];
                [distanceArray addObject:topLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureOriginY))){
                topRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureOriginY) toPoint:CGPointMake(cropperMaxX, _cropViewYOffset)]];
                [distanceArray addObject:topRight];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureMaxY))){
                bottomLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureMaxY) toPoint:CGPointMake(_cropViewXOffset, cropperMaxY)]];
                [distanceArray addObject:bottomLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureMaxY))){
                bottomRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureMaxY) toPoint:CGPointMake(cropperMaxX, cropperMaxY)]];
                [distanceArray addObject:bottomRight];
            }
            
            
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

@end
