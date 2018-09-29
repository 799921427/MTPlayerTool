//
//  ViewController.m
//  ToolView
//
//  Created by 张德茂 on 2018/9/3.
//  Copyright © 2018年 张德茂. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"nowViewHeight:%f",self.myView.frame.size.height);
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self animationBegin];
}

#pragma mark - AnimationBegin
- (void)animationBegin {
    [UIView animateWithDuration:5.0 animations:^{
        CGRect frame = self.myView.frame;
        NSLog(@"myViewHeight:%f",self.myView.frame.size.height);
        frame.size.height -= 300;
        NSLog(@"nowViewHeight:%f",frame.size.height);
        self.myView.frame = frame;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
