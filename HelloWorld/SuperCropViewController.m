//
//  SuperCropViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//


#import "SuperCropViewController.h"
#import "CameraViewController.h"
#import "MELDynamicCropView.h"

#define imageWidth                                       (320.0f)

@interface SuperCropViewController ()<CameraViewControllerDelegate, MELDynamicCropViewDelegate>
@property (nonatomic, strong) MELDynamicCropView     *superCrop;
@property (nonatomic, strong) UIImage                *image;
@property (nonatomic, strong) UILabel                *label;
@property (nonatomic, strong) UIImageView            *cropImageView;
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
    
    CGRect cropImageFrame = [[self cropImageView] frame];
    cropImageFrame.size     = CGSizeMake(imageWidth, imageWidth);
    cropImageFrame.origin.x = CGRectGetWidth([[self view] frame]) - cropImageFrame.size.width;
    [[self cropImageView] setFrame:cropImageFrame];

}

- (CGRect)cropFrame{
    CGRect cropFrame = CGRectZero;
    cropFrame.size      = CGSizeMake(imageWidth, imageWidth);
    cropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - cropFrame.size.height)/2;
    cropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - cropFrame.size.width)/2;
    return cropFrame;
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

- (MELDynamicCropView *)superCrop{
    if (!_superCrop){
        _superCrop = [[MELDynamicCropView alloc]initWithFrame:[self cropFrame] cropSize:CGSizeMake(imageWidth, imageWidth) maximumRadius:900.0f];
        [_superCrop setDelegate:self];
        //[_superCrop setAllowPinchOutsideOfRadius:YES];
    }
    return _superCrop;
}

- (void)CameraViewController:(CameraViewController *)controller didFinishCroppingImage:(UIImage *)image transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect{
    
    __block UIImage *anImage = image;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        
        if (anImage){
            _image = anImage;
            [[self superCrop] setImage:_image];
            //[crop setAllowPinchOutsideOfRadius:YES];
            [[self view] addSubview:[self superCrop]];
            
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
    [[self cropImageView] setImage:[[self superCrop] croppedImage]];
}

@end
