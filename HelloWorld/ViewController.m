//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Car.h"

/*this is a comment pushing down the vc */
@interface ViewController ()
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button0;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *addressEntity  = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:context];
    Car *car0 = [Car new];
//    Car *car0   = [[Car alloc] initWithEntity:addressEntity insertIntoManagedObjectContext:context];
//    [car0 setDriver:@"mike"];
//    
//    NSError *error = nil;
//    if (![context save:&error]) {
//        NSLog(@"save error: %@", error);
//    }else{
//        NSLog(@"save 0 ok");
//    }
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self textField] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self textField] setFrame:labelFrame];
    
    CGRect button0frame = [[self button0] frame];
    button0frame.size.height = 100.0f;
    button0frame.size.width = 100.0f;
    button0frame.origin.x = (CGRectGetWidth([[self view] frame]) - button0frame.size.width)/2;
    button0frame.origin.y = (CGRectGetHeight([[self view] frame]) - button0frame.size.height)/2;
    [[self button0] setFrame:button0frame];
    
    CGRect button1frame = [[self button1] frame];
    button1frame.size.height = 100.0f;
    button1frame.size.width = 100.0f;
    button1frame.origin.x = (CGRectGetWidth([[self view] frame]) - button1frame.size.width)/2;
    button1frame.origin.y = CGRectGetMaxY(button0frame) + 10.0f;
    [[self button1] setFrame:button1frame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextField *)textField{
    if (!_textField){
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_textField setText:@"CD"];
        [_textField setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_textField];
        return _textField;
    }
    return _textField;
}

- (UIButton *)button0{
    if (!_button0){
        _button0 = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button0 addTarget:self action:@selector(didTapZero:) forControlEvents:UIControlEventTouchUpInside];
        [_button0 setTitle:NSLocalizedString(@"BUTTON 0", nil) forState:UIControlStateNormal];
        [[self view] addSubview:_button0];
    }
    return _button0;
}

- (UIButton *)button1{
    if (!_button1){
        _button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button1 addTarget:self action:@selector(didTapOne:) forControlEvents:UIControlEventTouchUpInside];
        [_button1 setTitle:NSLocalizedString(@"Button 1", nil) forState:UIControlStateNormal];
        [[self view] addSubview:_button1];
    }
    return _button1;
}


- (void)didTapZero:(id)sender{
    [sender setTag:99];
    self.button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button2 addTarget:self action:@selector(didTapOne:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 setTitle:NSLocalizedString(@"BUTTON 2", nil) forState:UIControlStateNormal];
    [self.button2 sizeToFit];
    CGRect frame = self.button2.frame;
    frame.origin.y = 50.0f;
    [self.button2 setFrame:frame];
    [[self view] addSubview:self.button2];
    
}

- (void)didTapOne:(id)sender{
    [sender setTag:100];
}

@end
