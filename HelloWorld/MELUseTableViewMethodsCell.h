//
//  MELUseTableViewMethodsCell.h
//  HelloWorld
//
//  Created by Mike Leveton on 6/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kColdStartCellHeight                             (70.0f)
@protocol LWDynamicTableViewCellDelegate;

@interface MELUseTableViewMethodsCell : UITableViewCell
@property (nonatomic, weak) id <LWDynamicTableViewCellDelegate>  delegate;
@property (nonatomic, strong) UILabel                            *placeholder;
@property (nonatomic, strong) UITextView                         *textView;
@end

@protocol LWDynamicTableViewCellDelegate <NSObject>

@optional

/* sets the current text height for the delegate */
- (void)setUpheightForTextViewWithHeight:(CGFloat)height;

/* the cell asks its delegate for the current height */
- (CGFloat)getTextViewHeight;

/* calls setNeedsLayout for the cell and sets the content offset for the table */
- (void)adjustScrollViewWithHeight:(CGFloat)height;

/* persists the string to cd */
- (void)didUpdateText:(NSString *)text;

/* used by review property vc only which then uses the bool in keyboardWillShow */
- (void)adjustDynamicCellIsFirstResponder:(BOOL)isFirstResponder;

@end