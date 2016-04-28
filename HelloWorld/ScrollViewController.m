//
//  ScrollViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/27/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ScrollViewController.h"
#import "ZoomingImageScrollView.h"

@interface ScrollViewController ()
@property (nonatomic, strong) ZoomingImageScrollView *scrollView;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect scrollFrame = [[self view] frame];
    scrollFrame.origin.x  = -100;
    //scrollFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - scrollFrame.size.height)/2;
    scrollFrame.size.width = CGRectGetWidth([[self view] frame]) + 200;
    //scrollFrame.size.height = 300.0f;
    //[[self scrollView] setFrame:scrollFrame];
    [[self scrollView] setFrame:[[self view] frame]];
    [[self scrollView] setContentSize:CGSizeMake(scrollFrame.size.width, 0)];
    [[self scrollView] setImage:[UIImage imageNamed:@"pan"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ZoomingImageScrollView *)scrollView{
    if (!_scrollView){
        _scrollView = [[ZoomingImageScrollView alloc] initWithFrame:CGRectZero];
        //[_scrollView setImage:[UIImage imageNamed:@"pan"]];
        [[self view] addSubview:_scrollView];
        return _scrollView;
    }
    return _scrollView;
}


@end
