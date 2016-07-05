//
//  LWDynamicImageView.h
//  LifeWalletFramework
//
//  Created by Mike Leveton on 7/4/16.
//  Copyright © 2016 LifeWallet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWDyanimcImageViewDelegate;

@interface LWDynamicImageView : UIImageView
@property (nonatomic, assign) id <LWDyanimcImageViewDelegate> delegate;
@property (nonatomic, assign, readonly) CGRect innerFrame;

- (void)setInnerFrame:(CGRect)innerFrame;
@end

@protocol LWDyanimcImageViewDelegate <NSObject>
- (void)imageWasPinchedWithFrame:(CGRect)frame;

@end