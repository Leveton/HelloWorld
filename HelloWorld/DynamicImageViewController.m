//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "DynamicImageViewController.h"
#import "AppDelegate.h"
//#import "MELDynamicCropView.h"
#import "LWDynamicImageView.h"

@interface DynamicImageViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, LWDyanimcImageViewDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) NSIndexPath               *selectedIndex;
//@property (nonatomic, strong) UIImageView               *selectedImageView;
@property (nonatomic, strong) UIView                    *cropView;
@property (nonatomic, strong) UIImage                   *image;
@property (nonatomic, assign) CGSize                    cropSize;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, strong) LWDynamicImageView        *dynamicImageView;
@property (nonatomic, assign) CGAffineTransform         originalTransform;

@end

@implementation DynamicImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect collectionViewFrame = [[self collectionView] frame];
    collectionViewFrame.size   = CGSizeMake(CGRectGetWidth([[self view]frame]), CGRectGetHeight([[self view]frame]));
    [[self collectionView] setFrame:collectionViewFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - getters

- (UICollectionView *)collectionView{
    if (!_collectionView){
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        
        if (_cellSize.width < 0.1f){
            _cellSize = CGSizeMake(100.0f, 100.0f);
        }
        
        [flowLayout setItemSize:_cellSize];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:[UIColor blueColor]];
        [[self view] addSubview:_collectionView];
        return _collectionView;
    }
    return _collectionView;
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Messages"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIView *)cropView{
    if (!_cropView){
        _cropView = [[UIView alloc] initWithFrame:CGRectZero];
        //[[self view] addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

//- (UIImageView *)selectedImageView{
//    if (!_selectedImageView){
//        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
//        [_selectedImageView addGestureRecognizer:pan];
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
//        [_selectedImageView addGestureRecognizer:pinch];
//        [_selectedImageView setUserInteractionEnabled:YES];
//        [[self view] addSubview:_selectedImageView];
//        return _selectedImageView;
//    }
//    return _selectedImageView;
//}

- (LWDynamicImageView *)dynamicImageView{
    if (!_dynamicImageView){
        _dynamicImageView = [[LWDynamicImageView alloc] initWithFrame:CGRectZero];
        [_dynamicImageView setDelegate:self];
        [[self view] addSubview:_dynamicImageView];
    }
    return _dynamicImageView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"books"]];
    [imgView setFrame:cell.frame];
    [cell setBackgroundView:imgView];
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath;
    
    UICollectionViewCell *cell         = [[self collectionView] cellForItemAtIndexPath:indexPath];
    [[self dynamicImageView] setFrame:cell.frame];
    [[self dynamicImageView] setImage:[UIImage imageNamed:@"books"]];
    [cell setHidden:YES];
    
    
    CGRect wrapperFrame = CGRectZero;
    wrapperFrame.origin.x = self.view.bounds.origin.x - 50.0f;
    wrapperFrame.origin.y = self.view.bounds.origin.y - 50.0f;
    wrapperFrame.size.width = self.view.bounds.size.width + 100.0f;
    wrapperFrame.size.height = self.view.bounds.size.height + 100.0f;
    
    
    [UIView animateWithDuration:0.55f
                          delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            
                            [[self dynamicImageView] setFrame:wrapperFrame];
                            [[self dynamicImageView] setInnerFrame:self.view.bounds];
                            
                        }
                     completion:^(BOOL finished) {
                         [[self dynamicImageView] setFrame:wrapperFrame];
                         [[self dynamicImageView] setInnerFrame:self.view.bounds];
                     }];
    
}



#pragma mark - setters

- (void)setCellSize:(CGSize)cellSize{
    _cellSize = cellSize;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setItemSize:_cellSize];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [[self collectionView] setCollectionViewLayout:flowLayout];
}

- (void)setImage:(UIImage *)image{
    _image = image;
}

#pragma mark - LWDyanimcImageViewDelegate

- (void)imageWasPinchedWithFrame:(CGRect)frame{
    
    UICollectionViewCell *cell = [[self collectionView] cellForItemAtIndexPath:_selectedIndex];
    
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         CGRect frame = [cell frame];
                         if (_cellSize.width > 0){
                             frame.size.width  = _cellSize.width;
                             frame.size.height = _cellSize.height;
                         }
                         [[self dynamicImageView] setFrame:frame];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell setHidden:NO];
        [[self dynamicImageView] removeFromSuperview];
        _dynamicImageView = nil;
    });
}

@end
