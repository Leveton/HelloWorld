//
//  LWZoomingImageScrollView.h
//  Encounter
//
//  Created by Marin Fischer on 11/6/15.
//  Copyright © 2015 LifeWallet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWZoomImageScrollDelegate;

@interface ZoomingImageScrollView : UIScrollView
@property (nonatomic, weak) id <LWZoomImageScrollDelegate> zoomViewDelegate;
@property (nonatomic) NSUInteger                        index;
@property (nonatomic, strong) UIImageView               *imageZoomView;
@property (nonatomic, strong, readonly) NSString        *imageURL;
@property (nonatomic, strong, readonly) UIImage         *image;
@property (nonatomic, assign, readonly) CGFloat         originalWidth;
@property (nonatomic, assign, readonly) CGFloat         originalContentWidth;

- (void)setImageURL:(NSString *)imageURL;
- (void)setImage:(UIImage *)image;
- (void)setOriginalWidth:(CGFloat)originalWidth;
- (void)setOriginalContentWidth:(CGFloat)originalContentWidth;
@end

@protocol LWZoomImageScrollDelegate <NSObject>

@optional
- (void)imageWasPinchedWithScollView:(ZoomingImageScrollView *)view;
- (void)imageWasPinchedWithFrame:(CGRect)frame fromZoomingView:(ZoomingImageScrollView *)view;
@end