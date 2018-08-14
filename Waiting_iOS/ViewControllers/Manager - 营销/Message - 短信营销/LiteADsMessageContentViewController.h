//
//  LiteADsMessageContentViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import "LiteADsMessageListModel.h"

@interface LiteADsMessageContentViewController : LiteBaseViewController

@property (nonatomic , assign) MessageContentType type;
@property (nonatomic , strong) LiteADsMessageListModel * messageModel;


@end
