//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewTouchTarget.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UIView      *containerView;
@property (nonatomic, strong) ImageViewTouchTarget *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"enabled: %ld", (long)self.view.userInteractionEnabled);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect containerFrame = [[self containerView] frame];
    containerFrame.size.height = 100.0f;
    containerFrame.size.width = 100.0f;
    containerFrame.origin.y = (CGRectGetHeight([[self view]frame]) - containerFrame.size.height)/2;
    containerFrame.origin.x = (CGRectGetWidth([[self view]frame]) - containerFrame.size.width)/2;
    [[self containerView] setFrame:containerFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size.height = 300.0f;
    imageFrame.size.width = 300.0f;
    imageFrame.origin.y = (CGRectGetHeight([[self view]frame]) - imageFrame.size.height)/2;
    imageFrame.origin.x = (CGRectGetWidth([[self view]frame]) - imageFrame.size.width)/2;
    [[self imageView] setFrame:imageFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"TouchTargetUITouch"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIView *)containerView{
    if (!_containerView){
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [_containerView setBackgroundColor:[UIColor blueColor]];
        //[[self view] addSubview:_containerView];
        return _containerView;
    }
    return _containerView;
}

- (ImageViewTouchTarget *)imageView{
    if (!_imageView){
        _imageView = [[ImageViewTouchTarget alloc] initWithFrame:CGRectZero];
        [_imageView setImage:[UIImage imageNamed:@"Church"]];
        [_imageView setUserInteractionEnabled:YES];
        [[self view] addSubview:_imageView];
        return _imageView;
    }
    return _imageView;
}


@end
