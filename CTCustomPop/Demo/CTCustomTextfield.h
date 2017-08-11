//
//  CTCustomTextfield.h
//  Demo
//
//  Created by 咖啡豆 on 2017/8/4.
//  Copyright © 2017年 zhangjingwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTCustomTextfield : UITextField

- (void) addTimerDuration:(NSTimeInterval)second block:(void(^)())block;

@end
