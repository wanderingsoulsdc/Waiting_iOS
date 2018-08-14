//
//  LiteDeviceWorkStatusViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/5.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import <CoreLocation/CLLocation.h>
#import "LiteDeviceModel.h"

typedef NS_ENUM(NSUInteger, DeviceStatusType) {
    DeviceStatusTypeWorkNone,    //创建标签未工作
    DeviceStatusTypeWorking,     //设备工作中
    DeviceStatusTypeWorkPause,   //设备暂停中
};

@interface LiteDeviceWorkStatusViewController : LiteBaseViewController
//选定的经纬度坐标
@property (nonatomic , assign) CLLocationCoordinate2D coordinate;
//设备model
@property (nonatomic , strong) LiteDeviceModel  * deviceModel;
//设备工作状态
@property (nonatomic , assign) DeviceStatusType workType;

@end
