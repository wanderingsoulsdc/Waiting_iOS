//
//  MatchVideoViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/9/23.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "NTESNetChatViewController.h"
#import "BHUserModel.h"

NS_ASSUME_NONNULL_BEGIN
@class NetCallChatInfo;
@class NTESVideoChatNetStatusView;

@interface MatchVideoViewController : NTESNetChatViewController

@property (nonatomic , strong) BHUserModel * userModel;

@end

NS_ASSUME_NONNULL_END
