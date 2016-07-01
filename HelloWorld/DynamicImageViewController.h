//
//  DynamicImageViewController.h
//  HelloWorld
//
//  Created by Mike Leveton on 7/1/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicImageViewController : UIViewController
@property (nonatomic, assign, readonly) CGSize               cellSize;
- (void)setCellSize:(CGSize)cellSize;
@end
