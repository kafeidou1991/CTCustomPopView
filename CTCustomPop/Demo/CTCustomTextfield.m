//
//  CTCustomTextfield.m
//  Demo
//
//  Created by 咖啡豆 on 2017/8/4.
//  Copyright © 2017年 zhangjingwei. All rights reserved.
//

#import "CTCustomTextfield.h"
#define ButtonWidth 50

typedef void(^Block)();


@interface CTCustomTextfield  (){
    UIButton * timerBtn;
    NSTimer * captchaTimer;
    NSTimeInterval seconds;
    NSTimeInterval orginSecond;
    Block _block;
}


@end

@implementation CTCustomTextfield

- (void) addTimerDuration:(NSTimeInterval)second block:(void (^)())block {
    NSAssert(second >= 0, @"初始化秒数为0");
    orginSecond =second;
    [self _createGetCodeButton];
    _block = block;
}
- (void) _createGetCodeButton{
    timerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [timerBtn setTitle:@"验证码" forState:UIControlStateNormal];
    timerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [timerBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [timerBtn addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:timerBtn];
}
- (void)getCodeAction:(UIButton *)sender {
    
    if (_block) {
        _block();
    }
    [self _fireTimer];
    
    
}
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!CGRectIsEmpty(frame)) {
        if (timerBtn) {
         timerBtn.frame = CGRectMake(self.frame.size.width - ButtonWidth, (self.frame.size.height - MIN(30, self.frame.size.height))/2, ButtonWidth, MIN(30, self.frame.size.height));
        }
    }
}

- (void) _fireTimer {
    seconds = orginSecond;
    timerBtn.userInteractionEnabled = NO;
    [captchaTimer invalidate];
    captchaTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(runTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:captchaTimer forMode:NSDefaultRunLoopMode];
    [captchaTimer fire];
}

//计时器
- (void)runTimer:(NSTimer *)timer {
    seconds--;
    if (seconds == 0){
        [self validateCodeControl:@"重新发送"];
    }else{
        [timerBtn setTitle:[NSString stringWithFormat:@"(%ld)",(long)seconds] forState:UIControlStateNormal];
    }
}

- (void)validateCodeControl:(NSString*)title {
    [captchaTimer invalidate];
    captchaTimer = nil;
    [timerBtn setTitle:title forState:UIControlStateNormal];
    timerBtn.userInteractionEnabled = YES;
}









@end
