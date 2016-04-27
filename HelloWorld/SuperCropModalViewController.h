//
//  SuperCropModalViewController.h
//  HelloWorld
//
//  Created by Mike Leveton on 4/26/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperCropModalViewController : UIViewController
@property (nonatomic, strong, readonly) UIImage *image;

- (void)setImage:(UIImage *)image;
@end
