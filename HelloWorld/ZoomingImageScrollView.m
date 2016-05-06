//
//  LWZoomingImageScrollView.m
//  Encounter
//
//  Created by Marin Fischer on 11/6/15.
//  Copyright © 2015 LifeWallet. All rights reserved.
//


#import "ZoomingImageScrollView.h"

@interface ZoomingImageScrollView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@end

@implementation ZoomingImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [self setBackgroundColor:[UIColor whiteColor]];
//        [self setShowsVerticalScrollIndicator:YES];
//        [self setShowsHorizontalScrollIndicator:YES];
//        [self setScrollEnabled:YES];
//        [self setBounces:YES];
//        [self setPagingEnabled:NO];
//        [self setBouncesZoom:YES];
//        [self setDelaysContentTouches:YES];
//        [self setCanCancelContentTouches:YES];
//        [self setDelegate:self];
//        [self setUserInteractionEnabled:YES];
//        [self setMultipleTouchEnabled:YES];
//        [self setOpaque:YES];
//        [self setClearsContextBeforeDrawing:YES];
//        [self setClipsToBounds:YES];
//        [self setAutoresizesSubviews:YES];
//        [self setMinimumZoomScale:1.0f];
//        [self setMaximumZoomScale:5.0f];
//        [self setContentMode:UIViewContentModeScaleAspectFit];
//        [self setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
//        
//        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//        [doubleTap setNumberOfTapsRequired:2];
//        [doubleTap setNumberOfTouchesRequired:1];
//        [self addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:[self pinch]];
    }
    return self;
}

#pragma mark - Setters
- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setImage:(UIImage *)image{
    _image = image;
    [[self imageZoomView] setImage:_image];
}

- (void)setOriginalWidth:(CGFloat)originalWidth{
    _originalWidth = originalWidth;
}

- (void)setOriginalContentWidth:(CGFloat)originalContentWidth{
    _originalContentWidth = originalContentWidth;
}

#pragma mark - Views
- (UIImageView *)imageZoomView {
    if (!_imageZoomView) {
        _imageZoomView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageZoomView setBackgroundColor:[UIColor whiteColor]];
        [_imageZoomView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageZoomView];
        return _imageZoomView;
    }
    return _imageZoomView;
}

- (UIPinchGestureRecognizer *)pinch{
    if (!_pinch){
        _pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
    }
    return _pinch;
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageZoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{

}

#pragma mark - Private methods

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer{
    NSLog(@"zoomscale: %f", self.zoomScale);
    NSLog(@"rec scale: %f", recognizer.scale);
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    NSLog(@"content size: %f %f", self.contentSize.width, self.contentSize.height);
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"widths: %f %f", recognizer.view.frame.size.width, _originalWidth);
        CGFloat ratio = recognizer.view.frame.size.width/_originalWidth;
        [self setContentSize:CGSizeMake(_originalContentWidth*ratio, self.contentSize.height)];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    if (self.zoomScale == self.minimumZoomScale) {
        /* Zoom in */
        CGPoint center = [tapGestureRecognizer locationInView:self];
        CGSize size = CGSizeMake(self.bounds.size.width / self.maximumZoomScale,
                                 self.bounds.size.height / self.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self zoomToRect:rect animated:YES];
    }else {
        /* Zoom out */
        [self zoomToRect:self.bounds animated:YES];
    }
}


@end
