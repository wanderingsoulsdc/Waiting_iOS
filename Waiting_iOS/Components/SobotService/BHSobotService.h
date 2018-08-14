//
//  BHSobotService.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/12/4.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHSobotService : NSObject

/*  智齿客服Demo 和 部分问题解决办法
 https://github.com/ZCSDK/sobot_iOS_Demo
 */

/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;

- (void)startSoBotCustomerServiceWithViewController:(UIViewController *)viewController;

@end
