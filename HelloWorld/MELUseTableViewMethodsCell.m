//
//  MELUseTableViewMethodsCell.m
//  HelloWorld
//
//  Created by Mike Leveton on 6/13/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELUseTableViewMethodsCell.h"

#define kDynamicCellTextPadding                 (12.0f)

@interface MELUseTableViewMethodsCell()<UITextViewDelegate>
//@property (nonatomic, strong) NSDictionary                  *notesViewAttribs;
@property (nonatomic, assign) CGFloat                       lineHeightForTextView;
@property (nonatomic, assign) CGFloat                       textHeightForTextView;
@property (nonatomic, assign) NSInteger                     numberOfLinesForTextView;
@property (nonatomic, assign) NSInteger                     maxNumberOfLinesForTextView;
@end

@implementation MELUseTableViewMethodsCell

- (id)init{
    self = [super init];
    
    if (self){
        
        /*allow approx 100kb per note message */
        _maxNumberOfLinesForTextView = 3000;
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"layout subviews cell called");
    
    CGRect textViewFrame          = [[self textView] frame];
    textViewFrame.origin.x        = kDynamicCellTextPadding;
    textViewFrame.origin.y        = kDynamicCellTextPadding;
    
    if ([[self delegate] respondsToSelector:@selector(getTextViewHeight)]){
        CGFloat currentTextHeight = [[self delegate] getTextViewHeight] + kDynamicCellTextPadding;
        CGFloat minimumTextHeight = kColdStartCellHeight - (kDynamicCellTextPadding * 2);
        textViewFrame.size.height = (currentTextHeight > minimumTextHeight) ? currentTextHeight : minimumTextHeight;
    }
    
    textViewFrame.size.width      = CGRectGetWidth([self frame]) - (kDynamicCellTextPadding * 2);
    [[self textView] setFrame:textViewFrame];
    
    CGRect placeholderTextFrame      = [[self placeholder] frame];
    placeholderTextFrame.origin.x    = textViewFrame.origin.x;
    placeholderTextFrame.origin.y    = textViewFrame.origin.y;
    placeholderTextFrame.size.width  = textViewFrame.size.width;
    placeholderTextFrame.size.height = _lineHeightForTextView ? _lineHeightForTextView : 22.0f;
    [[self placeholder] setFrame:placeholderTextFrame];
}

#pragma mark - getters

-(UILabel *)placeholder{
    if (!_placeholder) {
        _placeholder = [[UILabel alloc] initWithFrame:CGRectZero];
        [_placeholder setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0f]];
        [_placeholder setTextColor:[UIColor grayColor]];
        [_placeholder.layer setZPosition:2.0f];
        [_placeholder setBackgroundColor:[UIColor redColor]];
        [self addSubview:_placeholder];
    }
    return _placeholder;
}

- (UITextView *)textView{
    if (!_textView){
        _textView = [[UITextView alloc]initWithFrame:CGRectZero];
        [_textView setDelegate:self];
        _textView.bounces = NO;
        [_textView setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0f]];
        [_textView setTextColor:[UIColor blackColor]];
        [_textView setBackgroundColor:[UIColor blueColor]];
        [self addSubview:_textView];
    }
    
    return _textView;
}

//- (NSDictionary *)notesViewAttribs{
//    if (!_notesViewAttribs){
//        _notesViewAttribs = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [UIFont fontWithName:@"Avenir-Roman" size:16.0f], NSFontAttributeName,
//                             nil];
//    }
//    return _notesViewAttribs;
//}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([self isEditing]){
        if ([[self delegate] respondsToSelector:@selector(adjustDynamicCellIsFirstResponder:)]){
            [[self delegate] adjustDynamicCellIsFirstResponder:YES];
        }
        [[self placeholder] setHidden:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if ([[self delegate] respondsToSelector:@selector(adjustDynamicCellIsFirstResponder:)]){
        [[self delegate] adjustDynamicCellIsFirstResponder:NO];
    }
    [[self placeholder] setHidden:[textView hasText]];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ((_numberOfLinesForTextView > _maxNumberOfLinesForTextView) && ![text isEqualToString:@""]){
        return NO;
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView{
    
    [[self placeholder] setHidden:[textView hasText]];
    
    if ([[self delegate] respondsToSelector:@selector(didUpdateText:)]){
        [[self delegate] didUpdateText:textView.text];
    }
    
    //NSString *text = textView.text;
    
    //CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth([[self textView]bounds]), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[self notesViewAttribs] context:nil].size.height;
    
    
    CGFloat width      = CGRectGetWidth([self frame]) - (kDynamicCellTextPadding * 2);
    CGSize size        = [[self textView] sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat textHeight = size.height;
    NSLog(@"text view did change %f %f", textHeight, _textHeightForTextView);
    
    /* if line height not set */
    if (_lineHeightForTextView < 1){
        _lineHeightForTextView = textHeight;
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView++;
    }
    
    /* if there's a new line */
    if (textHeight > _textHeightForTextView){
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView++;
        if ([[self delegate] respondsToSelector:@selector(setUpheightForTextViewWithHeight:)]){
            [[self delegate] setUpheightForTextViewWithHeight:_textHeightForTextView];
        }
        if ([[self delegate] respondsToSelector:@selector(adjustScrollViewWithHeight:)]){
            [[self delegate] adjustScrollViewWithHeight:_lineHeightForTextView];
        }
    }
    
    /* this is for the back button/ delete button */
    if (textHeight < _textHeightForTextView){
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView--;
        if ([[self delegate] respondsToSelector:@selector(setUpheightForTextViewWithHeight:)]){
            [[self delegate] setUpheightForTextViewWithHeight:_textHeightForTextView];
        }
        if ([[self delegate] respondsToSelector:@selector(adjustScrollViewWithHeight:)]){
            [[self delegate] adjustScrollViewWithHeight:-_lineHeightForTextView];
        }
    }
    

}
@end
