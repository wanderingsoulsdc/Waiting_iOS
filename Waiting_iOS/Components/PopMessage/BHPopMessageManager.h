//
//  BHPopMessageManager.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/12.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHPopMessageManager : NSObject

/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;

- (void)showPopMessageWithData:(NSDictionary *)dict inViewController:(UIViewController *)viewController;
- (void)showPopMessage;

- (void)showPopMessageNoviceGuide;

@end
