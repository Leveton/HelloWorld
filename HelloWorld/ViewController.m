//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//


/*Cropper - Only check out of bounds on cropper if it's at the stop event and then pop back*/


#import "ViewController.h"
#import "CameraViewController.h"
#import "UIImage+Additions.h"
//#import "UIImage+PhotoCrop.h"
#import "CropView.h"

#define imageWidth                                       (320.0f)
#define imageToCropWidth                                 (340.0f)
#define kImageRadius                                     (8.0f)

@interface ViewController ()<CameraViewControllerDelegate>
@property (nonatomic, strong) UIImage     *image;
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cropImageView;
@property (nonatomic, strong) CropView    *cropView;
@property (nonatomic, strong) UIImageView *imageToCrop;
@property (nonatomic, strong) UIView      *gestureView;
@property (nonatomic, assign) CGFloat     trackerScale;
@property (nonatomic, assign) CGFloat     cropViewXOffset;
@property (nonatomic, assign) CGFloat     cropViewYOffset;
@property (nonatomic, assign) CGFloat     minimumImageXOffset;
@property (nonatomic, assign) CGFloat     minimumImageYOffset;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y    = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size     = CGSizeMake(imageWidth, imageWidth);
    [[self imageView] setFrame:imageFrame];
    
    CGRect cropImageFrame = [[self cropImageView] frame];
    cropImageFrame.size     = CGSizeMake(imageWidth, imageWidth);
    cropImageFrame.origin.x = CGRectGetWidth([[self view] frame]) - cropImageFrame.size.width;
    [[self cropImageView] setFrame:cropImageFrame];
    
    CGRect cropFrame = [[self cropView] frame];
    cropFrame.size      = CGSizeMake(imageWidth, imageWidth);
    cropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - cropFrame.size.height)/2;
    //cropFrame.origin.y  = 50.0f;
    cropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - cropFrame.size.width)/2;
    //cropFrame.origin.x  = 50.0f;
    [[self cropView] setFrame:cropFrame];
    
    _cropViewXOffset = cropFrame.origin.x;
    _cropViewYOffset = cropFrame.origin.y;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - views

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Crop"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_label addGestureRecognizer:tap];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_imageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_imageView layer] setBorderWidth:1.0f];
        [_imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_imageView addGestureRecognizer:tap];
        //[[self view] addSubview:_imageView];
    }
    return _imageView;
}

- (UIImageView *)cropImageView{
    if (!_cropImageView){
        _cropImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_cropImageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_cropImageView layer] setBorderWidth:1.0f];
        [_cropImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCrop:)];
        [_cropImageView addGestureRecognizer:tap];
        [[self view] addSubview:_cropImageView];
    }
    return _cropImageView;
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

- (CropView *)cropView{
    if (!_cropView){
        _cropView = [[CropView alloc] initWithFrame:CGRectZero];
        [_cropView setBackgroundColor:[UIColor blueColor]];
        [[_cropView layer] setOpacity:0.2f];
        [[_cropView layer] setZPosition:1.0f];
        [_cropView setUserInteractionEnabled:YES];
        [[self view] addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

- (UIView *)gestureView{
    if (!_gestureView){
        _gestureView = [[UIView alloc]initWithFrame:CGRectZero];
        [_gestureView setBackgroundColor:[UIColor clearColor]];
        [_gestureView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        [_gestureView addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
        [_gestureView addGestureRecognizer:pinch];
        [_gestureView setHidden:YES];
        [[self view] addSubview:_gestureView];
        return _gestureView;
    }
    
    return _gestureView;
}

#pragma mark - camera

- (void)presentCamera{
    
    CameraViewController *camera = [[CameraViewController alloc]init];
    [camera setCameraShouldDefaultToFront:NO];
    [camera setViewFinderHasOverlay:YES];
    [camera setAllowsFlipCamera:YES];
    [camera setAllowsFlash:YES];
    [camera setAllowsPhotoRoll:YES];
    [camera setDelegate:self];
    [camera setShouldResizeToViewFinder:NO];
    [camera setCardSize:CGSizeMake(imageWidth, imageWidth)];
    [self presentViewController:camera animated:YES completion:^{
        
        [[camera view] setNeedsLayout];
    }];
}

- (void)CameraViewController:(CameraViewController *)camera didFinishWithImage:(UIImage *)image{
    
    CGFloat cameraWidth  = camera.viewFinderSize.width;
    CGFloat cameraHeight = camera.viewFinderSize.height;
    __block UIImage *anImage = image;
    
    [camera dismissViewControllerAnimated:YES completion:^{
        
        anImage = [anImage scaleProportionalToSize:CGSizeMake(cameraWidth, cameraHeight)];
        //todo: figure out why 1.5 works. it's a hack.
        anImage = [anImage croppedImageFromImage:anImage withSize:CGSizeMake(imageWidth*1.5, imageWidth*1.5)];
        anImage = [anImage makeRoundedImage:anImage radius:kImageRadius];
        
        [[self imageView] setImage:anImage];
        
    }];
    
}

- (void)CameraViewController:(CameraViewController *)controller didFinishCroppingImage:(UIImage *)image transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect{
    
    __block UIImage *anImage = image;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        //anImage = [anImage makeRoundedImage:anImage radius:kImageRadius];
        
        if (anImage){
            //[[self imageView] setImage:anImage];
            _image = anImage;
            
            //[[self imageToCrop] setFrame:[self frameForGestureViewWithImage:image]];
            [[self gestureView] setFrame:[self frameForGestureViewWithImage:anImage]];
            //[[self imageToCrop] setFrame:[[self gestureView] frame]];
            
            CGRect imageFrame = [[self imageToCrop] frame];
            imageFrame.origin.x     = 0.0f;
            imageFrame.origin.y     = 0.0f;
            imageFrame.size.width   = _gestureView.bounds.size.width;
            imageFrame.size.height  = _gestureView.bounds.size.height;
            [[self imageToCrop] setFrame:imageFrame];
            
            _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - _imageToCrop.bounds.size.width;
            _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - _imageToCrop.bounds.size.height;
            [[self imageToCrop] setImage:_image];
            [[self gestureView] setHidden:NO];
            
        }else{
            NSLog(@"reached no animage");
        }
        
    }];
}

#pragma mark - selectors


- (CGRect)frameForGestureViewWithImage:(UIImage *)image{
    
    CGFloat proportion;
    CGFloat newHeight;
    CGFloat newWidth;
    
    if (image.size.width >= image.size.height){
        /* make the height 5/4ths the size of the crop view */
        proportion            = image.size.width/image.size.height;
        newHeight             = [[self cropView] bounds].size.height * (5.0f/4.0f);
        newWidth              = newHeight * proportion;
        
    }else{
        /* make the width 5/4ths the size of the crop view */
        proportion             = image.size.height/image.size.width;
        newWidth               = [[self cropView] bounds].size.width * (5.0f/4.0f);
        newHeight              = newWidth * proportion;
    }
    
    CGRect  dynamicImageViewFrame = [[self gestureView] frame];
    dynamicImageViewFrame.size.width  = newWidth;
    dynamicImageViewFrame.size.height = newHeight;
    dynamicImageViewFrame.origin.x    = _cropViewXOffset -  (newWidth - _cropView.bounds.size.width)/2;
    dynamicImageViewFrame.origin.y    = _cropViewYOffset -  (newHeight - _cropView.bounds.size.height)/2;
    return dynamicImageViewFrame;
}

- (void)didTap:(id)sender{
    [self presentCamera];
}

- (void)didTapCrop:(id)sender{
    [[self cropImageView] setImage:self.croppedImage];
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
    //        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    //        recognizer.scale = 1;
    
    
    
    
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _trackerScale = [recognizer scale];
        
        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan ||
        [recognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        //_currentImageScale = currentScale;
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.2;
        const CGFloat kMinScale = 0.64;
        
        CGFloat newScale = 1 -  (_trackerScale - [recognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[recognizer view] transform], newScale, newScale);
        [recognizer view].transform = transform;
        
        [recognizer setScale:1.0];
        
        _trackerScale = [recognizer scale];  // Store the previous scale factor for the next pinch gesture call
        
        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
    }
}

#pragma mark - image selectors

- (UIImage *)croppedImage{
    //return [_image rotatedImageWithtransform:self.imageViewRotation croppedToRect:[self currentCropRect]];;
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
    
    CGSize size = image.size;
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,
                                           image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
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
