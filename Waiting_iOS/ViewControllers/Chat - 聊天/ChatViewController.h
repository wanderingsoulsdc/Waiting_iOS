//
//  ChatViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/9/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "NIMKit.h"
#import "ChatSessionConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : NIMSessionViewController

@property (nonatomic, strong) ChatSessionConfig * chatConfig;

@property (nonatomic,assign) BOOL disableCommandTyping;  //需要在导航条上显示“正在输入”

@property (nonatomic,assign) BOOL disableOnlineState;  //需要在导航条上显示在线状态

@end

NS_ASSUME_NONNULL_END
