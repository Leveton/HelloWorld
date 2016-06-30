//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MELDynamicCropView.h"
#import "Car.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, LWDynamicImageViewDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionView                   *collectionView;
@property (nonatomic, strong) NSIndexPath                        *selectedIndex;
@property (nonatomic, strong) MELDynamicCropView                 *zoomView;
@end

@implementation ViewController

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

- (MELDynamicCropView *)zoomView{
    if (!_zoomView){
        _zoomView = [[MELDynamicCropView alloc]initWithFrame:CGRectZero cropFrame:CGRectZero];
        [_zoomView setDelegate:self];
        //[_cropViewRight setBackgroundColor:[UIColor clearColor]];
        [_zoomView setCropColor:[UIColor clearColor]];
        [_zoomView setCropAlpha:0.0f];
    }
    return _zoomView;
}

- (void)setCellSize:(CGSize)cellSize{
    _cellSize = cellSize;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setItemSize:_cellSize];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [[self collectionView] setCollectionViewLayout:flowLayout];
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
    [cell setHidden:YES];
    UIImage *selectedImage = [UIImage imageNamed:@"books"];
    
    //dont allow selection if we do not have an image.
    if (!selectedImage) {
        return;
    }
    
    [[self zoomView] setFrame:[cell frame]];
    [[self zoomView] setHidden:NO];
    [[self zoomView] setImage:selectedImage];
    [[self collectionView] addSubview:[self zoomView]];
    
    CGRect wrapperFrame = CGRectZero;
    wrapperFrame.origin.x = self.view.bounds.origin.x - 50.0f;
    wrapperFrame.origin.y = self.view.bounds.origin.y - 50.0f;
    wrapperFrame.size.width = self.view.bounds.size.width + 100.0f;
    wrapperFrame.size.height = self.view.bounds.size.height + 100.0f;
    
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(50.0f, 50.0f);
    frame.size   = CGSizeMake(CGRectGetWidth([[self view]bounds]), CGRectGetHeight([[self view]bounds]));
    
    [UIView animateWithDuration:0.55f
                          delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            
                            [[self zoomView] setFrame:wrapperFrame];
                            [[self zoomView] setCropFrame:frame];
                            [[self zoomView] setImage:selectedImage];
                            //[[[self zoomView] imageZoomView] setFrame:self.view.bounds];
                        }
                     completion:^(BOOL finished) {
                         [[self zoomView] setFrame:wrapperFrame];
                         [[self zoomView] setCropFrame:frame];
                         [[self zoomView] setImage:selectedImage];
                         //[[[self zoomView] imageZoomView] setFrame:self.view.bounds];
                         //[[self cancelBarButtonItem] setAction:@selector(didCancelZoomedView:)];
                     }];
    
}

#pragma mark - LWDynamicImageViewDelegate

- (void)imageWasPinchedWithFrame:(CGRect)frame{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"books"]];
    [imageView setFrame:frame];
    [[self collectionView] addSubview:imageView];
    
    [[self zoomView] removeFromSuperview];
    _zoomView = nil;
    
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
                         [imageView setFrame:frame];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.41 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [imageView removeFromSuperview];
        [[self zoomView] removeFromSuperview];
        _zoomView = nil;
        [cell setHidden:NO];
    });
}

@end
