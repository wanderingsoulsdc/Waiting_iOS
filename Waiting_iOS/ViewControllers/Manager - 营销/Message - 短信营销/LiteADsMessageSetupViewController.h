//
//  LiteADsMessageSetupViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"

@interface LiteADsMessageSetupViewController : LiteBaseViewController

@property (nonatomic , assign) MessageContentType type;
@property (nonatomic , strong) NSMutableDictionary     * formDic;

@end
