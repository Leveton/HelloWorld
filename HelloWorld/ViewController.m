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

@interface ViewController ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button0;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self simpleBlock];
//    [self blockWithCopyScope];
//    [self blockWithReferenceScopeAndTypeDef];
//    
//    /* run this a few times to see default and high switch places */
//    [self GCDWithDequeueOrder];
    
    /* shows that all code is executed/assigned within the block before the group is called */
    [self dispatchGroupWithDelay];
    
}

- (void)simpleBlock{
    int (^MyBlock)(int) = ^(int num) { return num * 3; };
    int aNum = MyBlock(3);
    
    NSLog(@"Num %i",aNum); //9

}

- (void)blockWithCopyScope{
    int spec = 4;
    
    int (^MyBlock)(int) = ^(int aNum){
        return aNum * spec;
    };
    
    spec = 0;
    NSLog(@"Block value is %d",MyBlock(4));
}

- (void)blockWithReferenceScopeAndTypeDef{
    __block int spec = 4;
    
    typedef int (^MyBlock)(int);
    
    MyBlock InBlock = ^(int aNum){
        return aNum * spec;
    };
    
    spec = 0;
    NSLog(@"InBlock value is %d",InBlock(4));
}

- (void)GCDWithDequeueOrder{
    dispatch_queue_t low = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0);
    dispatch_queue_t defaultQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_queue_t high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_async(low, ^{
        
        NSLog(@"low");
    });
    dispatch_async(defaultQ, ^{
        
        NSLog(@"default");
    });
    dispatch_async(high, ^{
        
        NSLog(@"hight");
    });
}

- (void)GCDWithDequeueOrder2{
    dispatch_queue_t low = dispatch_queue_create("low",0);
    dispatch_queue_t defaultQ = dispatch_queue_create("med",0);
    dispatch_queue_t high = dispatch_queue_create("high",0);
    dispatch_async(low, ^{
        
        NSLog(@"low");
    });
    dispatch_async(defaultQ, ^{
        
        NSLog(@"default");
    });
    dispatch_async(high, ^{
        
        NSLog(@"hight");
    });
}

- (void)dispatchGroupWithDelay{
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group,queue,^{
        NSLog(@"Block 1");
    });
    
    dispatch_group_async(group,queue,^{
        NSLog(@"Block 2");
        sleep(5);
        NSLog(@"Block 3");
    });
    
    dispatch_group_notify(group,queue,^{
        NSLog(@"Final block is executed last after 1, 2, sleep, and 3");
    });
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
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

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"CD"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
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
