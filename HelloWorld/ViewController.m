//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//





//use the expanding table view cells in profile




#import "ViewController.h"
#import "AppDelegate.h"
#import "MELExpandingTextCell.h"
#import "MELTextViewTableViewCell.h"
#import "MELUseTableViewMethodsCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, LWDynamicTableViewCellDelegate>
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString    *notesString;
@property (nonatomic, assign) CGFloat     textHeightForNotesView;
@property (nonatomic, assign) CGFloat     notesOffset;
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
    
    CGRect tableFrame = [[self tableView] frame];
    tableFrame.origin.y = CGRectGetMaxY(labelFrame);
    tableFrame.size.height = CGRectGetHeight([[self view] frame]) - tableFrame.origin.y;
    tableFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self tableView] setFrame:tableFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Dynamic"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setAllowsSelectionDuringEditing:YES];
        [_tableView setEditing:YES];
        [[self view] addSubview:_tableView];
    }
    return _tableView;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 3){
        MELExpandingTextCell *cell = [MELExpandingTextCell new];
        //[cell setDelegate:self];
        [[cell placeholder] setText:@"hi mike"];
        [[cell placeholder] setHidden:YES];
        [cell setEditing:YES];
        return cell;
    }
    
    if (indexPath.row == 5){
        MELUseTableViewMethodsCell *cell = [MELUseTableViewMethodsCell new];
        [cell setDelegate:self];
        [[cell textView] setText:_notesString];
        [[cell placeholder] setText:@"hi mike 7"];
        [[cell placeholder] setHidden:YES];
        [cell setEditing:YES];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 5){
        NSLog(@"notes height > cold start: %ld", (long)(self.textHeightForNotesView > kColdStartCellHeight));
        return (self.textHeightForNotesView > kColdStartCellHeight) ? self.textHeightForNotesView : kColdStartCellHeight;
    }
    return kColdStartCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //MELExpandingTextCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[[cell textView] becomeFirstResponder];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - MELExpandingTextCellDelegate

- (void)setUpheightForTextViewWithHeight:(CGFloat)height{
    NSLog(@"setUpheightForTextViewWithHeight called with height %f", height);
    _textHeightForNotesView = height;
}

- (CGFloat)getTextViewHeight{
    NSLog(@"getTextViewHeight called with height %f", _textHeightForNotesView);
    return _textHeightForNotesView;
}
- (void)adjustScrollViewWithHeight:(CGFloat)height{
    NSLog(@"adjustScrollViewWithHeight called");
    self.notesOffset = self.notesOffset + height;
    
//    if ([self tableViewShouldScroll]){
//        [[self tableView] setContentOffset:CGPointMake(0, self.notesOffset) animated:YES];
//    }
    //NSIndexPath *indexPath           = [NSIndexPath indexPathForRow:5 inSection:0];
    [[self tableView] beginUpdates];
    //[[self tableView] reloadRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
    //MELUseTableViewMethodsCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    //[cell layoutSubviews];
}
- (void)didUpdateText:(NSString *)text{
    _notesString = text;
}
- (void)adjustDynamicCellIsFirstResponder:(BOOL)isFirstResponder{
    /* for keyboard will show notif */
}

@end
