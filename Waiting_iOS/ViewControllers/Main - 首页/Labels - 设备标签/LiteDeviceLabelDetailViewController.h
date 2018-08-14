//
//  LiteDeviceLabelDetailViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/12.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import "LiteLabelModel.h"

@protocol LiteLabelDetailDelegate <NSObject>

@optional
//操作成功需要刷新页面
- (void)changeLabelNameSuccess:(LiteLabelModel *)labelModel;

- (void)deleteLabelSuccess:(LiteLabelModel *)labelModel;

@end

@interface LiteDeviceLabelDetailViewController : LiteBaseViewController

@property (nonatomic , strong) LiteLabelModel  * labelModel;

@property (nonatomic , assign) id <LiteLabelDetailDelegate> delegate;

@end
