//
//  FSNetWorkError.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/28.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNetWorkError : NSObject

/**
 *  根据服务器返回的errorcode获取错误描述
 *
 *  @param errorCode 服务器返回的errorcode
 *
 *  @return 对应的错误描述
 */
+ (NSString *)checkNetWorkErrorCode:(NSNumber *)errorCode;

@end
