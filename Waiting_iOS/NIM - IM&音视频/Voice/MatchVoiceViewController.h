//
//  MatchVoiceViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/9/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "NTESNetChatViewController.h"
#import "BHUserModel.h"

NS_ASSUME_NONNULL_BEGIN
@class NetCallChatInfo;
@class NTESVideoChatNetStatusView;

@interface MatchVoiceViewController : NTESNetChatViewController

@property (nonatomic , strong) BHUserModel  * userModel;

@property (nonatomic , strong) NSString     * tvId;

@end

NS_ASSUME_NONNULL_END
