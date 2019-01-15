//
//  EnumHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef EnumHeader_h
#define EnumHeader_h

/** 注册/找回密码 */
typedef enum : NSUInteger {
    ResetPassWordTypeRegister,
    ResetPassWordTypeForget,
    ResetPassWordTypeReset
} BHResetPassWordType;

typedef NS_ENUM(NSUInteger, MyInputType) {
    MyInputTypeTextField,     //一行输入框
    MyInputTypeTextView,     //多行文本输入框
    MyInputTypeGender,       //性别选择
    MyInputTypeInterest,     //爱好选择
};

#endif /* EnumHeader_h */
