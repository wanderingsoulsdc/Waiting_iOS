//
//  ChatListModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatListModel : NSObject

@property (nonatomic, strong) NSString      * headImageUrl;     //头像链接
@property (nonatomic, strong) NSString      * userName;         //用户昵称
@property (nonatomic, strong) NSString      * content;          //内容简介
@property (nonatomic, strong) NSString      * badge;            //角标
@property (nonatomic, strong) NSString      * lastTime;         //最后发消息时间

@end
