//
//  CTCustomPopView.h
//  Demo
//
//  Created by 咖啡豆 on 2017/8/1.
//  Copyright © 2017年 zhangjingwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(UIButton * btn);

@interface CTCustomPopView : UIView

//！！注： 目前只支持 textfield 在上 button在下


//点击背景隐形部分时候隐藏弹框 默认是NO
@property (nonatomic, assign) BOOL clickBackgroundHide;
//用来获取输入框内容
@property (nonatomic, strong, readonly) NSArray * textFieldsArray;

/**
 标题字体大小 默认18
 */
@property (nonatomic, strong) UIFont * titleFont;
/**
 标题字体颜色 默认黑色
 */
@property (nonatomic, strong) UIColor * titleColor;
/**
 消息字体大小 默认16
 */
@property (nonatomic, strong) UIFont * messageFont;
/**
 消息字体颜色  默认黑色
 */
@property (nonatomic, strong) UIColor * messageColor;
/**
 按钮字体颜色 默认17
 */
@property (nonatomic, strong) UIFont * buttonFont;
/**
 输入框的颜色 默认15
 */
@property (nonatomic, strong) UIFont * textFieldFont;
/**
 输入框字体颜色 默认黑色
 */
@property (nonatomic, strong) UIColor * textFieldColor;

/**
 分割线的颜色 默认 lightGray
 */
@property (nonatomic, strong) UIColor * lineColor;

#pragma mark - Method
/**
 初始化方法  顶部title 跟描述内容

 @param title 标题
 @param message 描述
 @return self
 */
- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message;

/**
 添加一个button

 @param title 按钮文字
 @param color 按钮颜色
 @param block 点击回调
 */
- (void)addCustomButton:(NSString * )title buttonTextColor:(UIColor * )color clickBlock:(ClickBlock)block;

/**
 添加一个textfield

 @param placeholder 提示文字
 @param text 内容
 @param secureEntry 是否开启安全
 */
- (void)addCustomTextFieldForPlaceholder:(NSString *)placeholder text:(NSString *)text secureEntry:(BOOL)secureEntry;

/**
 呈现在superView

 @param view 父视图
 */
- (void)showPopView:(UIView *)view;


@end
