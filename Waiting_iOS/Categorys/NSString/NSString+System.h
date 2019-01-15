//
//  NSString+System.h
//  iPresale
//
//  Created by ChenQiuLiang on 15/10/8.
//  Copyright © 2015年 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (System)

// 得到设备uuid
+ (NSString *)getIOSUUID;

// 得到APP版本号
+ (NSString *)getAppVersion;



// 得到手机Version
+ (NSString *)getIPhoneVersion;

// 得到设备系统的版本号
+ (NSString *)getDeviceSystemVersion;

@end
