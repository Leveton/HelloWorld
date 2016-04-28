//
//  ZoomingImageScrollView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/6/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ZoomingImageScrollView.h"

@interface ZoomingImageScrollView() <UIScrollViewDelegate>

@end
@implementation ZoomingImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setShowsVerticalScrollIndicator:YES];
        [self setShowsHorizontalScrollIndicator:YES];
        [self setScrollEnabled:YES];
        [self setBounces:YES];
        [self setPagingEnabled:NO];
        [self setBouncesZoom:YES];
        [self setDelaysContentTouches:YES];
        [self setCanCancelContentTouches:YES];
        [self setDelegate:self];
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:YES];
        [self setOpaque:YES];
        [self setClearsContextBeforeDrawing:YES];
        [self setClipsToBounds:YES];
        [self setAutoresizesSubviews:YES];
        [self setMinimumZoomScale:1.0f];
        [self setMaximumZoomScale:5.0f];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        [self setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [doubleTap setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - Setters
- (void)setImage:(UIImage *)image{
    _image = image;
    [[self imageZoomView] setImage:_image];
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

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageZoomView;
}


#pragma mark - Private methods


- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.zoomScale == self.minimumZoomScale) {
        // Zoom in
        CGPoint center = [tapGestureRecognizer locationInView:self];
        CGSize size = CGSizeMake(self.bounds.size.width / self.maximumZoomScale,
                                 self.bounds.size.height / self.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self zoomToRect:rect animated:YES];
    }
    else {
        // Zoom out
        [self zoomToRect:self.bounds animated:YES];
    }
}


@end
