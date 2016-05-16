//
//  SuperCropViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "SuperCropModalViewController.h"
#import "SuperCropViewController.h"
#import "CameraViewController.h"
#import "MELDynamicCropView.h"
#import "MELSuperCropView.h"
#import "MELCropView.h"
#import "MELPortableCropView.h"

#define imageWidth                                       (200.0f)

@interface SuperCropViewController ()<CameraViewControllerDelegate, MELDynamicCropViewDelegate, MELSuperCropViewDelegate, MELPortableCropViewDelegate, MELCropViewDelegate>
@property (nonatomic, strong) MELDynamicCropView     *dynamicCrop;
@property (nonatomic, strong) MELSuperCropView       *superCrop;
@property (nonatomic, strong) MELPortableCropView    *portableCrop;
@property (nonatomic, strong) MELCropView            *melCropView;
@property (nonatomic, strong) UIImage                *image;
@property (nonatomic, strong) UILabel                *label;
@property (nonatomic, strong) UIImageView            *cropImageView;
@property (nonatomic, strong) UILabel                *showLabel;
@end

@implementation SuperCropViewController

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
    
    CGRect showLabelFrame = [[self showLabel] frame];
    showLabelFrame.size.height = 60.0f;
    showLabelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    showLabelFrame.origin.y    = CGRectGetHeight([[self view] frame]) - showLabelFrame.size.height;
    [[self showLabel] setFrame:showLabelFrame];
    
//    CGRect cropImageFrame = [[self cropImageView] frame];
//    cropImageFrame.size     = CGSizeMake(imageWidth, imageWidth);
//    cropImageFrame.origin.x = CGRectGetWidth([[self view] frame]) - cropImageFrame.size.width;
//    [[self cropImageView] setFrame:cropImageFrame];

}

- (CGRect)cropFrame{
    CGRect cropFrame = CGRectZero;
    cropFrame.size      = CGSizeMake(imageWidth, imageWidth);
    cropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - cropFrame.size.height)/2;
    cropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - cropFrame.size.width)/2;
    return cropFrame;
}

- (CGRect)randomFrame0{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(500, 500);
    frame.origin = CGPointMake(300, 300);
    return frame;
}

- (CGRect)randomFrame1{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(100, 100);
    frame.origin = CGPointMake(100, 100);
    return frame;
}

- (CGRect)randomFrame2{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(500, 500);
    frame.origin = CGPointMake(300, 300);
    return frame;
}

- (CGRect)randomFrame3{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(100, 100);
    frame.origin = CGPointMake(100, 100);
    return frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - views

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Present"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setUserInteractionEnabled:YES];
        [[_label layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_label addGestureRecognizer:tap];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UILabel *)showLabel{
    if (!_showLabel){
        _showLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_showLabel setText:@"Show"];
        [_showLabel setTextAlignment:NSTextAlignmentCenter];
        [_showLabel setUserInteractionEnabled:YES];
        [[_showLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCrop:)];
        [_showLabel addGestureRecognizer:tap];
        [[self view] addSubview:_showLabel];
        return _showLabel;
    }
    return _showLabel;
}

- (UIImageView *)cropImageView{
    if (!_cropImageView){
        _cropImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_cropImageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_cropImageView layer] setBorderWidth:1.0f];
        [_cropImageView setUserInteractionEnabled:YES];
        [[_cropImageView layer] setZPosition:4.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCrop:)];
        [_cropImageView addGestureRecognizer:tap];
        //[[self view] addSubview:_cropImageView];
    }
    return _cropImageView;
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

- (MELDynamicCropView *)dynamicCrop{
    if (!_dynamicCrop){
        _dynamicCrop = [[MELDynamicCropView alloc]initWithFrame:[self cropFrame] cropSize:CGSizeMake(320.0f, 420.0f) maximumRadius:900.0f];
        [_dynamicCrop setBackgroundColor:[UIColor redColor]];
        [_dynamicCrop setCropColor:[UIColor greenColor]];
        [_dynamicCrop setCropAlpha:0.5f];
        [_dynamicCrop setDelegate:self];
        [_dynamicCrop setAllowPinchOutsideOfRadius:YES];
    }
    return _dynamicCrop;
}

- (MELSuperCropView *)superCrop{
    if (!_superCrop){
        _superCrop = [[MELSuperCropView alloc]initWithFrame:[self cropFrame] cropSize:CGSizeMake(320.0f, 420.0f) maximumRadius:900.0f];
        [_superCrop setBackgroundColor:[UIColor redColor]];
        [_superCrop setCropColor:[UIColor greenColor]];
        [_superCrop setCropAlpha:0.5f];
        [_superCrop setDelegate:self];
        [_superCrop setAllowPinchOutsideOfRadius:YES];
    }
    return _superCrop;
}

- (MELPortableCropView *)portableCrop{
    if (!_portableCrop){
        _portableCrop = [[MELPortableCropView alloc]initWithFrame:[self cropFrame] cropSize:CGSizeMake(420.0f, 320.0f) maximumRadius:900];
        [_portableCrop setBackgroundColor:[UIColor redColor]];
        [_portableCrop setCropColor:[UIColor greenColor]];
        [_portableCrop setCropAlpha:0.5f];
        [_portableCrop setDelegate:self];
    }
    return _portableCrop;
}

- (MELCropView *)melCropView{
    if (!_melCropView){
        _melCropView = [[MELCropView alloc]initWithFrame:[self cropFrame] cropSize:CGSizeMake(50.0f, 50)];
        [_melCropView setBackgroundColor:[UIColor redColor]];
        [_melCropView setCropColor:[UIColor greenColor]];
        [_melCropView setCropAlpha:0.5f];
        [_melCropView setDelegate:self];
    }
    return _melCropView;
}

- (void)CameraViewController:(CameraViewController *)controller didFinishCroppingImage:(UIImage *)image transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect{
    
    __block UIImage *anImage = image;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        
        if (anImage){
            _image = anImage;
            //[[self dynamicCrop] setImage:_image];
            //[[self view] addSubview:[self dynamicCrop]];
            //[[self superCrop] setImage:_image];
            //[[self view] addSubview:[self superCrop]];
            //[[self portableCrop] setImage:_image];
            //[[self view] addSubview:[self portableCrop]];
            [[self melCropView] setImage:_image];
            [[self view] addSubview:[self melCropView]];
            NSLog(@"total view width: %f", self.view.frame.size.width);
            
        }else{
            NSLog(@"reached no animage");
        }
        
    }];
}

#pragma mark - selectors

- (void)didTap:(id)sender{
    [self presentCamera];
}

- (void)didTapCrop:(id)sender{
    //[[self cropImageView] setImage:[[self superCrop] croppedImage]];
    SuperCropModalViewController *vc = [[SuperCropModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self melCropView] croppedImage]];
    [vc setImageSize:[[self melCropView] cropSize]];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
