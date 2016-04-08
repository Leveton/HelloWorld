//
//  LWCameraViewController.h
//  Encounter
//
//  Created by Mike Leveton on 8/23/15.
//  Copyright (c) 2015 LifeWallet. All rights reserved.
//

typedef enum : NSUInteger {
    LWCameraOrientationBackCamera,
    LWCameraOrientationFrontCamera
} LWCameraOrientation;

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class LWCameraViewController;

@protocol LWCameraViewControllerDelegate;

@interface LWCameraViewController : UIViewController

@property (nonatomic) CGRect imageCropRect;
@property (nonatomic, weak) id <LWCameraViewControllerDelegate> delegate;
@property (nonatomic, assign) CGSize cardSize;
@property (nonatomic, assign) CGSize viewFinderSize;
@property (nonatomic, assign, readonly) BOOL allowsPhotoRoll;
@property (nonatomic, assign, readonly) BOOL allowsFlash;
@property (nonatomic, assign, readonly) BOOL allowsFlipCamera;
@property (nonatomic, assign, readonly) BOOL viewFinderHasOverlay;
@property (nonatomic, assign, readonly) BOOL cameraShouldDefaultToFront;
@property (nonatomic, assign, readonly) BOOL shouldResizeToViewFinder;


- (void)setAllowsPhotoRoll:(BOOL)allowsPhotoRoll;
- (void)setAllowsFlash:(BOOL)allowsFlash;
- (void)setAllowsFlipCamera:(BOOL)allowsFlipCamera;
- (void)setViewFinderHasOverlay:(BOOL)viewFinderHasOverlay;
- (void)setCameraShouldDefaultToFront:(BOOL)cameraShouldDefaultToFront;
- (void)setShouldResizeToViewFinder:(BOOL)shouldResizeToViewFinder;

/*!
 Use this to close camera - Otherwise, the captureSession may not close properly and may result in memory leaks.
 */
- (void)closeWithCompletion:(void (^)(void))completion;

- (void)didTapCapturePhoto;

@end

@protocol LWCameraViewControllerDelegate<NSObject>

@required
- (void)LWCameraViewController:(LWCameraViewController *)camera didFinishWithImage:(UIImage *)image;
- (void)LWCameraViewController:(LWCameraViewController *)controller didFinishCroppingImage:(UIImage *)image transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect;

@optional

- (void)cameraDidLoadCameraIntoView:(LWCameraViewController *)camera;

@end
