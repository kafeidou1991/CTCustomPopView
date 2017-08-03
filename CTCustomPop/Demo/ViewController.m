//
//  ViewController.m
//  Demo
//
//  Created by 咖啡豆 on 2017/7/28.
//  Copyright © 2017年 zhangjingwei. All rights reserved.
//

#import "ViewController.h"
#import "CTCustomPopView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)action:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)action:(id)sender {
    
    CTCustomPopView * view = [[CTCustomPopView alloc]initWithTitle:@"自定义弹出框" message:@"自定义弹出框详细信息自定义弹出框详细信息自定义弹出框详细信息自定义弹出框详细信息自定义弹出框详细信息自定义弹出框详细信息"];
    __weak typeof(CTCustomPopView) *weakPopUpView = view;
    view.clickBackgroundHide = YES;
    view.titleFont = [UIFont systemFontOfSize:18];
    view.titleColor = [UIColor blackColor];
    view.messageFont = [UIFont systemFontOfSize:16];
    view.messageColor = [UIColor grayColor];
    view.buttonFont = [UIFont systemFontOfSize:15];
    view.textFieldFont = [UIFont systemFontOfSize:15];
    view.lineColor = [UIColor lightGrayColor];
    view.textFieldColor = [UIColor blackColor];
    
    [view addCustomButton:@"自定义按钮1" buttonTextColor:[UIColor redColor] clickBlock:^(UIButton * btn) {
        NSLog(@"%ld",btn.tag);
        for (int i = 0; i < weakPopUpView.textFieldsArray.count; i ++) {
            UITextField *tf = weakPopUpView.textFieldsArray[i];
            NSLog(@"第%d个输入框的文字是：%@----tag:%ld", i, tf.text,tf.tag);
        }
    }];
    [view addCustomButton:@"自定义按钮2" buttonTextColor:[UIColor purpleColor] clickBlock:^(UIButton * btn) {
        NSLog(@"%ld",btn.tag);
        
    }];

    [view addCustomTextFieldForPlaceholder:@"自定义输入框1" text:@"" secureEntry:NO];
    [view addCustomTextFieldForPlaceholder:@"自定义输入框2" text:@"" secureEntry:NO];

    [view showPopView:self.view];
    
}
@end
