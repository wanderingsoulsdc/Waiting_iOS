//
//  LiteDeviceDetailViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/3.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"

@protocol   LiteDeviceDetailEditSuccessDelegate <NSObject>

- (void)LiteDeviceDetailEditSuccess;

@end

@interface LiteDeviceDetailViewController : LiteBaseViewController

@property (nonatomic , strong) NSString           * deviceId;

@property (nonatomic , assign) id <LiteDeviceDetailEditSuccessDelegate> delegate;

@end
