//
//  LiteDeviceModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiteLabelModel.h"

@interface LiteDeviceModel : NSObject

@property (nonatomic, strong) NSString      * deviceId;         //设备ID (取id)
@property (nonatomic, strong) NSString      * deviceName;       //设备名称
@property (nonatomic, strong) NSString      * netStatus;        //联网状态 1 未联网 2 已联网
@property (nonatomic, strong) NSString      * status;           //设备状态 1 正常  2 已解绑
@property (nonatomic, strong) NSString      * sign;             //标记工作状态 1 正在工作中 2 已暂停工作 3 创建标签
@property (nonatomic, strong) NSString      * mac;              //设备mac
@property (nonatomic, strong) NSString      * expiryTime;       //到期时间
@property (nonatomic, strong) NSString      * activeTime;       //激活时间
@property (nonatomic, strong) NSString      * expiryDay;        //到期剩余天数
@property (nonatomic, strong) NSString      * expiryStatus;     //激活状态 1 未激活 2 激活 3 停用
@property (nonatomic, strong) NSString      * labelNum;         //标签数
@property (nonatomic, strong) NSString      * labelTodayNum;    //今日创建标签数
@property (nonatomic, strong) NSString      * labelId;          //labelId大于0 ,代表设备中含有正在创建或暂停的标签

@property (nonatomic, strong) NSString      * personNum;        //覆盖人数

@property (nonatomic, strong) NSString      * startLatitude;    //设备最后位置纬度
@property (nonatomic, strong) NSString      * startLongitude;   //设备最后位置经度

@property (nonatomic, strong) NSArray<LiteLabelModel *>       * labelArray;

@end
