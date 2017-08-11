//
//  CTCustomPopView.m
//  Demo
//
//  Created by 咖啡豆 on 2017/8/1.
//  Copyright © 2017年 zhangjingwei. All rights reserved.
//

#import "CTCustomPopView.h"
#import "CTCustomTextfield.h"
#import "ScreenBlurry.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define TitleLabelFont [UIFont systemFontOfSize:18]
#define TitleLabelTextColor [UIColor blackColor]
#define MessageLabelFont [UIFont systemFontOfSize:15]
#define ButtonFont [UIFont systemFontOfSize:15]
#define TextFieldFont [UIFont systemFontOfSize:15]

#define LineBackGroundColor [UIColor lightGrayColor] //分割线的颜色

static CGFloat const animationDuration = 0.25f; //动画持续时间
static CGFloat const contentViewWidth = 250.f;  //显示内容宽度
static CGFloat const buttonHeight = 50.f;      //按钮高度
static CGFloat const textFieldHeight = 33.f;   //输入框的高度
static CGFloat const space = 5.f; //title message textfield btn 上下的间隙
static CGFloat const titleLeftOrRightSpace = 25.f; //title与contentview 左右间隙
static CGFloat const messageLeftOrRightSpace = 15.f; //message与contentView 左右间隙
static CGFloat const lineHeight = .5f;  //控件之间的分割线宽
static CGFloat const textfieldLeftOrRightSpace = 20.f; //textfield与contentView左右之间的间隙

@interface CTCustomPopView ()<UIGestureRecognizerDelegate,UITextFieldDelegate> {
    NSString * titleStr;
    NSString * messageStr;
    CGFloat contentHeight;  //显示视图高度
}

@property (nonatomic, strong) UIView * contentView; // 显示的内容视图
@property (nonatomic, strong) UILabel * titleLabel; // 顶部显示的title
@property (nonatomic, strong) UILabel * messageLabel; //描述信息label
@property (nonatomic, strong) NSMutableArray * controlsArray;  //存放button 或者textfield的数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *  buttonsArray; //  全局 谁为了 计算键盘弹出 是否需要frame改变
@property (nonatomic, strong) NSMutableArray * clickBlockArray;  //存放点击block的回调
@property (nonatomic, strong) NSMutableArray * textFieldMaxValueArray; //存放输入框可输入的最大值
@end

@implementation CTCustomPopView

#pragma mark - init Medthod
-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    if (self = [super init]) {
        titleStr = title;
        messageStr = message;
        contentHeight = space;
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4]; //黑色半透明
        self.alpha = 0;
        
        [self _initPropertyValue];
        [self _initUI];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}
//点击 收起视图
- (void)clickBackAction:(UITapGestureRecognizer *)tap {
    [self endEditing:YES];
    if (self.clickBackgroundHide) {
       [self _hiddenPopView];
    }
}

- (void)_initPropertyValue{
    self.titleFont = TitleLabelFont;
    self.titleColor = TitleLabelTextColor;
    self.messageFont = MessageLabelFont;
    self.messageColor = TitleLabelTextColor;
    self.buttonFont = ButtonFont;
    self.textFieldFont = TextFieldFont;
    self.textFieldColor = TitleLabelTextColor;
    self.lineColor = LineBackGroundColor;
}


#pragma custom control
- (void)addCustomButton:(NSString *)title buttonTextColor:(UIColor *)color clickBlock:(ClickBlock)block{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [self.clickBlockArray addObject:block];
    [_contentView addSubview:button];
    [self.controlsArray addObject:button];
}
//点击button
- (void)btnAction:(UIButton *)sender {
    ClickBlock block = self.clickBlockArray[sender.tag - 1000];
    if (block) {
        block(sender);
    }
    [self _hiddenPopView];
}

- (void)addCustomTextFieldForPlaceholder:(NSString *)placeholder maxInputCharacter:(int)maxValue text:(NSString *)text secureEntry:(BOOL)secureEntry {
    CTCustomTextfield * textfield = [[CTCustomTextfield alloc] init];
    textfield.text = text;
    textfield.placeholder = placeholder;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.secureTextEntry = secureEntry;
    textfield.delegate = self;
    [_contentView addSubview:textfield];
    [textfield addTimerDuration:10 block:^{
        NSLog(@"点击了验证码");
    }];
    [self.controlsArray addObject:textfield];
    [self.textFieldMaxValueArray addObject:@(maxValue)];
}
#pragma mark - load subView frame
- (void) _layoutSubViewsFrame {
    //分别设置frame
    [self _setTitleLabelFrame];
    [self _setMessageLabelFrame];
    [self _setControlsFrame];
    
    _contentView.frame = CGRectMake(0, 0, contentViewWidth, contentHeight);
    _contentView.center = self.center;
    
}
//title Frame
- (void) _setTitleLabelFrame {
    if (!titleStr || [titleStr isEqualToString:@""]) {
        contentHeight += self.titleSpace;
        return;
    }
    //目前只支持 单行显示  后期如果需要多行可以再此处 添加多行
    _titleLabel.font = self.titleFont;
    _titleLabel.text = titleStr;
    _titleLabel.textColor = self.titleColor;
    CGFloat titleHeight = 15.f;
    _titleLabel.frame = CGRectMake(titleLeftOrRightSpace, contentHeight, contentViewWidth - 2 * titleLeftOrRightSpace, titleHeight);
    contentHeight += titleHeight + self.titleSpace;
}

//message Frame
- (void) _setMessageLabelFrame {
    if (!messageStr || [messageStr isEqualToString:@""]) {
        contentHeight += self.messageSpace;
        return;
    }
    _messageLabel.text = messageStr;
    _messageLabel.font = self.messageFont;
    _messageLabel.textColor = self.messageColor;
    CGSize size = [_messageLabel.text boundingRectWithSize:CGSizeMake(contentViewWidth - 2 * messageLeftOrRightSpace, 250) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _messageLabel.font} context:nil].size;
    
    _messageLabel.frame =  CGRectMake(messageLeftOrRightSpace, contentHeight, contentViewWidth - 2 * messageLeftOrRightSpace, size.height);
    
    contentHeight = _messageLabel.frame.origin.y + _messageLabel.frame.size.height + self.messageSpace;
}
//controls Frame
- (void) _setControlsFrame {
    if (self.controlsArray.count <= 0) {
        return;
    }
    //检查数组  使textfield 始终放在button前面显示
    self.buttonsArray = @[].mutableCopy;
    NSMutableArray * textFieldsMuArray = @[].mutableCopy;
    for (id obj in self.controlsArray) {
        if ([obj isKindOfClass:[CTCustomTextfield class]]) {
            [textFieldsMuArray addObject:obj];
        }else if ([obj isKindOfClass:[UIButton class]]){
            [self.buttonsArray addObject:obj];
        }
    }
    //此处的顺序不可变
    if (textFieldsMuArray.count > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [self _setTextFieldFrame:textFieldsMuArray];
        _textFieldsArray = textFieldsMuArray.copy;
    }
    
    if (self.buttonsArray.count > 0) {
        [self _setButtonsFrame:self.buttonsArray];
    }
}
//textfield frame
- (void)_setTextFieldFrame:(NSMutableArray *)textfieldArray {
    //背景图 边框图
    UIView *textFieldBgView = [[UIView alloc]init];
    textFieldBgView.layer.masksToBounds = YES;
    textFieldBgView.layer.cornerRadius = 4;
    textFieldBgView.layer.borderWidth = 0.5;
    textFieldBgView.layer.borderColor = self.lineColor.CGColor;
    [_contentView addSubview:textFieldBgView];
    //以防遮挡 textfield
    [_contentView sendSubviewToBack:textFieldBgView];
    
    CGFloat top = contentHeight;
    for (int i = 0; i < textfieldArray.count; i ++) {
        CTCustomTextfield * textfield = textfieldArray[i];
        textfield.tag = 100 + i;
        textfield.font = self.textFieldFont;
        textfield.textColor = self.textFieldColor;
        textfield.frame = CGRectMake(textfieldLeftOrRightSpace, top + (textFieldHeight + lineHeight ) * i, contentViewWidth - 2 * textfieldLeftOrRightSpace, textFieldHeight);
        // Line 横线
        if (i != textfieldArray.count - 1) {
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = self.lineColor.CGColor;
            lineLayer.frame = CGRectMake(textfieldLeftOrRightSpace, top + textFieldHeight + (textFieldHeight + lineHeight) * i, contentViewWidth - 2 * textfieldLeftOrRightSpace, lineHeight);
            [_contentView.layer addSublayer:lineLayer];
        }
    }
    
    CTCustomTextfield *lastTf = textfieldArray.lastObject;
    textFieldBgView.frame = CGRectMake(textfieldLeftOrRightSpace, top, contentViewWidth - 2 * textfieldLeftOrRightSpace, CGRectGetMaxY(lastTf.frame) - top);
    
    contentHeight += CGRectGetHeight(textFieldBgView.frame) + space;
}
//button frame
- (void) _setButtonsFrame:(NSMutableArray *)buttonsArray {
    //当前按钮是2个的时候 并排显示
    CGFloat top = contentHeight;
    if (buttonsArray.count == 2) {
        // Line 横线
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = self.lineColor.CGColor;
        lineLayer.frame = CGRectMake(0, top, contentViewWidth, lineHeight);
        [_contentView.layer addSublayer:lineLayer];
        //竖线
        CALayer *lineLayer2 = [CALayer layer];
        lineLayer2.backgroundColor = self.lineColor.CGColor;
        lineLayer2.frame = CGRectMake(contentViewWidth/2.0, top + lineHeight, lineHeight, buttonHeight);
        [_contentView.layer addSublayer:lineLayer2];
        
        for (int i = 0; i < buttonsArray.count; i ++) {
            UIButton *button = buttonsArray[i];
            button.tag = 1000 + i;
            button.titleLabel.font = self.buttonFont;
            button.frame = CGRectMake(contentViewWidth /2.0* i, top + lineHeight, contentViewWidth / 2.0, buttonHeight);
        }
        contentHeight = lineHeight + buttonHeight + top;
    }else{
        for (int i = 0; i < buttonsArray.count; i ++) {
            //按钮上面的横线
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = self.lineColor.CGColor;
            lineLayer.frame = CGRectMake(0, top + (buttonHeight + lineHeight) * i, contentViewWidth, lineHeight);
            [_contentView.layer addSublayer:lineLayer];
            
            UIButton *button = buttonsArray[i];
            button.tag = 1000 + i;
            button.titleLabel.font = self.buttonFont;
            button.frame = CGRectMake(0,top + (buttonHeight + lineHeight) * i + lineHeight, contentViewWidth , buttonHeight);
        }
        contentHeight += (buttonHeight + lineHeight) * buttonsArray.count;
    }
}
#pragma mark - pop Medthod & animation
- (void)showPopView {
    [self _layoutSubViewsFrame];
    [self _showPopAnimation];
    //将视图添加
    [ScreenBlurry addBlurryScreenImageRadius:5];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    //背景渐变
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 1.0;
    }];
}

- (void) _hiddenPopView {
    [ScreenBlurry removeBlurryScreenImage];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self _hiddenPopAnimation];
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 0;
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) _showPopAnimation {
    
    CAKeyframeAnimation * keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    keyAnimation.keyTimes = @[@0,@0.5,@1.0]; //每帧动画时间
    keyAnimation.duration = animationDuration;
    keyAnimation.removedOnCompletion = YES;
    keyAnimation.fillMode = kCAFillModeForwards;
    //每帧 值  x,y,z 放大倍数
    keyAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                            ];
    [_contentView.layer addAnimation:keyAnimation forKey:nil];
}

- (void) _hiddenPopAnimation {
    CAKeyframeAnimation * keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    keyAnimation.keyTimes = @[@0,@0.5,@1.0]; //每帧动画时间
    keyAnimation.removedOnCompletion = YES;
    keyAnimation.fillMode = kCAFillModeRemoved;
    keyAnimation.duration = animationDuration;
    keyAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1)]];
    [_contentView.layer addAnimation:keyAnimation forKey:nil];
}
#pragma mark - init Views
//加载子视图
- (void) _initUI {
    [self addSubview:self.contentView];
    [_contentView addSubview:self.titleLabel];
    [_contentView addSubview:self.messageLabel];
    
}

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.clipsToBounds = YES;
        _contentView.layer.cornerRadius = 8.f;
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        //        _titleLabel.numberOfLines = 0; //可换行
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

-(NSMutableArray *)controlsArray {
    if (!_controlsArray) {
        _controlsArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _controlsArray;
}
- (NSMutableArray *)clickBlockArray {
    if (!_clickBlockArray) {
        _clickBlockArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _clickBlockArray;
}
- (NSMutableArray *)textFieldMaxValueArray {
    if (!_textFieldMaxValueArray) {
        _textFieldMaxValueArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _textFieldMaxValueArray;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSNumber * maxValue = self.textFieldMaxValueArray[textField.tag - 100];
    if (textField.text.length >= maxValue.integerValue) {
        return NO;
    }
    return YES;
}
#pragma mark - GestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_contentView.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - keyboard notifo
- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary * userInfo = [noti userInfo];
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect kbRect = [userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    CGFloat kb_minY = kScreenHeight - CGRectGetHeight(kbRect);
    
    CGRect beginUserInfo = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue];
    if (beginUserInfo.size.height <=0) {
        //兼容第三方键盘 搜狗输入法弹出时会发出三次UIKeyboardWillShowNotification的通知,和官方输入法相比,有效的一次为UIKeyboardFrameBeginUserInfoKey.size.height都大于零时.
        return;
    }
    CGFloat contentView_maxY = CGRectGetMaxY(_contentView.frame)+(5) - ((self.buttonsArray.count % 2 == 0) ? buttonHeight : buttonHeight * self.buttonsArray.count); //+5让输入框再高于键盘5的高度  - 按钮的高度
    CGFloat offset = contentView_maxY - kb_minY;
    if (offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            CGRect rect = _contentView.frame;
            rect.origin.y -= offset;
            _contentView.frame = rect;
        }];
    }
}
- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary * userInfo = [noti userInfo];
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:duration animations:^{
        _contentView.center = self.center;
    }];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
