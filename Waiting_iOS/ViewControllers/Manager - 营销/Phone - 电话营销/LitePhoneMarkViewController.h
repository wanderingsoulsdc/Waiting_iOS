//
//  LitePhoneMarkViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import "LiteADsPhoneListModel.h"

@interface LitePhoneMarkViewController : LiteBaseViewController

@property (nonatomic , strong) NSString         * logId;//电话历史id

@property (nonatomic , strong) NSString         * logTime;//电话历史时间戳

@property (nonatomic , strong) LiteADsPhoneListModel * phoneModel;

@end
