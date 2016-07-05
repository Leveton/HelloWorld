//
//  LWDynamicImageView.m
//  LifeWalletFramework
//
//  Created by Mike Leveton on 7/4/16.
//  Copyright © 2016 LifeWallet. All rights reserved.
//

#import "LWDynamicImageView.h"

@interface LWDynamicImageView()
@property (nonatomic, assign) CGSize                    cropSize;
//@property (nonatomic, assign) CGFloat                   cropViewXOffset;
//@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, assign) CGAffineTransform         originalTransform;
@end

@implementation LWDynamicImageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
        [self addGestureRecognizer:pinch];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}


#pragma mark - setters
- (void)setInnerFrame:(CGRect)innerFrame{
    _innerFrame = innerFrame;

}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    _copiedImage = [image copy];
    _originalTransform = self.transform;
    _minimumImageXOffset = (_innerFrame.origin.x + _innerFrame.size.width) - self.bounds.size.width;
    _minimumImageYOffset = (_innerFrame.origin.y + _innerFrame.size.height) - self.bounds.size.height;

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
        
        if (originX < _innerFrame.origin.x && originY < _innerFrame.origin.y && originX > _minimumImageXOffset && originY > _minimumImageYOffset){
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }else{
            
            [[pan view] setFrame:imageFrame];
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded){
        _minimumImageXOffset = (_innerFrame.origin.x + _innerFrame.size.width) - pan.view.frame.size.width;
        _minimumImageYOffset = (_innerFrame.origin.y + _innerFrame.size.height) - pan.view.frame.size.height;
    }
}

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    NSLog(@"recognizer.scale: %f %f %f", self.bounds.size.width, self.frame.origin.x, self.frame.origin.y);
    if (self.frame.size.width < 270.0f && [[self delegate] respondsToSelector:@selector(imageWasPinchedWithFrame:)]){
        [[self delegate] imageWasPinchedWithFrame:self.frame];
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded){
        
        /* first check if the new x and y offsets are too far below or too far above the cropper, gesture will get stuck if you let this go */
        
        CGFloat gestureOriginX = recognizer.view.frame.origin.x;
        CGFloat gestureOriginY = recognizer.view.frame.origin.y;
        CGFloat gestureMaxX    = gestureOriginX + recognizer.view.frame.size.width;
        CGFloat gestureMaxY    = gestureOriginY + recognizer.view.frame.size.height;
        CGFloat cropperMaxX    = _innerFrame.origin.x + _cropSize.width;
        CGFloat cropperMaxY    = _innerFrame.origin.x + _cropSize.height;
        
        bool outOfBounds       = (cropperMaxX > gestureMaxX || cropperMaxY > gestureMaxY || gestureOriginX > _innerFrame.origin.x || gestureOriginY > _innerFrame.origin.y);
        
        CGFloat gestureWidth   = [recognizer view].frame.size.width;
        CGFloat gestureHeight  = [recognizer view].frame.size.height;
        
        bool disAllowedPinch   = (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height);
        
        if (outOfBounds || disAllowedPinch){
            
            NSMutableArray *distanceArray = [NSMutableArray array];
            NSNumber *topLeft;
            NSNumber *topRight;
            NSNumber *bottomLeft;
            NSNumber *bottomRight;
            
            if (CGRectContainsPoint(_innerFrame, CGPointMake(gestureOriginX, gestureOriginY))){
                topLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureOriginY) toPoint:CGPointMake(_innerFrame.origin.x, _innerFrame.origin.y)]];
                [distanceArray addObject:topLeft];
            }
            if (CGRectContainsPoint(_innerFrame, CGPointMake(gestureMaxX, gestureOriginY))){
                topRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureOriginY) toPoint:CGPointMake(cropperMaxX, _innerFrame.origin.y)]];
                [distanceArray addObject:topRight];
            }
            if (CGRectContainsPoint(_innerFrame, CGPointMake(gestureOriginX, gestureMaxY))){
                bottomLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureMaxY) toPoint:CGPointMake(_innerFrame.origin.x, cropperMaxY)]];
                [distanceArray addObject:bottomLeft];
            }
            if (CGRectContainsPoint(_innerFrame, CGPointMake(gestureMaxX, gestureMaxY))){
                bottomRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureMaxY) toPoint:CGPointMake(cropperMaxX, cropperMaxY)]];
                [distanceArray addObject:bottomRight];
            }
            
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self setTransform:_originalTransform];
                                 [self setImage:_copiedImage];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }else{
            _minimumImageXOffset = (_innerFrame.origin.x + _innerFrame.size.width)  - recognizer.view.frame.size.width;
            _minimumImageYOffset = (_innerFrame.origin.y + _innerFrame.size.height) - recognizer.view.frame.size.height;
        }
    }
}

- (CGFloat)distanceFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB{
    return sqrt((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
}

@end
