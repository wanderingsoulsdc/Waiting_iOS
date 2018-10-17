//
//  ChatSessionConfig.h
//  Waiting_iOS
//
//  Created by wander on 2018/10/17.
//  Copyright © 2018 BEHE. All rights reserved.
//  聊天组件的注入配置
//  NIMKit 的聊天组件需要开发者通过注入一系列协议接口来进行聊天相关的排版布局和功能逻辑的扩展。 通过以下四个协议的注入配置，可实现聊天界面的基本设置。
//  NIMSessionConfig 协议主要定义了消息气泡和输入框相关功能的配置，自定义扩展需要新建一个类去实现该接口。注入配置示例代码如下

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatSessionConfig : NSObject<NIMSessionConfig>

@end

NS_ASSUME_NONNULL_END
