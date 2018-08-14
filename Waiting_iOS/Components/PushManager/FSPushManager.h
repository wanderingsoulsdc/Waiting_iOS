//
//  FSPushManager.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/10/23.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface FSPushManager : NSObject

/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;

/*
 *   处理推送消息
 */
- (void)handingPushNotificationDictionary:(NSDictionary *)userInfo;

@end
