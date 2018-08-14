//
//  LiteADsMessageHistoryViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import "LiteADsMessageListModel.h"

@protocol LiteADsMessageHistoryDelegate <NSObject>

@optional
- (void)messageHistorySelectResult:(LiteADsMessageListModel *)model;

@end

@interface LiteADsMessageHistoryViewController : LiteBaseViewController

@property (nonatomic , assign) id <LiteADsMessageHistoryDelegate> delegate;


@end
