//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "DynamicImageViewController.h"
#import "AppDelegate.h"
#import "MELDynamicCropView.h"
#import "Car.h"

@interface DynamicImageViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, LWDynamicImageViewDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) NSIndexPath               *selectedIndex;
@property (nonatomic, strong) UIImageView               *selectedImageView;
@property (nonatomic, strong) UIView                    *cropView;
@property (nonatomic, strong) UIImage                   *image;
@property (nonatomic, assign) CGSize                    cropSize;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, strong) UIImage                   *copiedImage;
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

- (UIImageView *)selectedImageView{
    if (!_selectedImageView){
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        [_selectedImageView addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
        [_selectedImageView addGestureRecognizer:pinch];
        [_selectedImageView setUserInteractionEnabled:YES];
        [[self view] addSubview:_selectedImageView];
        return _selectedImageView;
    }
    return _selectedImageView;
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
    [[self selectedImageView] setFrame:cell.frame];
    [[self selectedImageView] setImage:[UIImage imageNamed:@"books"]];
    [cell setHidden:YES];
    
    
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
                            
                            [[self selectedImageView] setFrame:wrapperFrame];
                            [[self cropView] setFrame:frame];
                            
                        }
                     completion:^(BOOL finished) {
                         [[self selectedImageView] setFrame:wrapperFrame];
                         [[self cropView] setFrame:frame];
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

#pragma mark - LWDynamicImageViewDelegate

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
                         [[self selectedImageView] setFrame:frame];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.41 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell setHidden:NO];
    });
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
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    NSLog(@"recognizer.scale: %f %f %f", _selectedImageView.bounds.size.width, _selectedImageView.frame.origin.x, _selectedImageView.frame.origin.y);
    if (_selectedImageView.frame.size.width < 270.0f){
        
        [self imageWasPinchedWithFrame:_selectedImageView.frame];
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded){
        
        /* first check if the new x and y offsets are too far below or too far above the cropper, gesture will get stuck if you let this go */
        
        CGFloat gestureOriginX = recognizer.view.frame.origin.x;
        CGFloat gestureOriginY = recognizer.view.frame.origin.y;
        CGFloat gestureMaxX    = gestureOriginX + recognizer.view.frame.size.width;
        CGFloat gestureMaxY    = gestureOriginY + recognizer.view.frame.size.height;
        CGFloat cropperMaxX    = _cropViewXOffset + _cropSize.width;
        CGFloat cropperMaxY    = _cropViewYOffset + _cropSize.height;
        //bool outOfBounds       = NO;
        
        bool outOfBounds       = (cropperMaxX > gestureMaxX || cropperMaxY > gestureMaxY || gestureOriginX > _cropViewXOffset || gestureOriginY > _cropViewYOffset);
        
        CGFloat gestureWidth   = [recognizer view].frame.size.width;
        CGFloat gestureHeight  = [recognizer view].frame.size.height;
        
        bool disAllowedPinch   = (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height);
        
        if (outOfBounds || disAllowedPinch){
            
            NSMutableArray *distanceArray = [NSMutableArray array];
            NSNumber *topLeft;
            NSNumber *topRight;
            NSNumber *bottomLeft;
            NSNumber *bottomRight;
            
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureOriginY))){
                topLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureOriginY) toPoint:CGPointMake(_cropViewXOffset, _cropViewYOffset)]];
                [distanceArray addObject:topLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureOriginY))){
                topRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureOriginY) toPoint:CGPointMake(cropperMaxX, _cropViewYOffset)]];
                [distanceArray addObject:topRight];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureMaxY))){
                bottomLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureMaxY) toPoint:CGPointMake(_cropViewXOffset, cropperMaxY)]];
                [distanceArray addObject:bottomLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureMaxY))){
                bottomRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureMaxY) toPoint:CGPointMake(cropperMaxX, cropperMaxY)]];
                [distanceArray addObject:bottomRight];
            }
            
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [[self selectedImageView] setTransform:_originalTransform];
                                 [self setImage:_copiedImage];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }else{
            _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width)  - recognizer.view.frame.size.width;
            _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - recognizer.view.frame.size.height;
        }
    }
}

- (CGFloat)distanceFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB{
    return sqrt((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
}
@end
