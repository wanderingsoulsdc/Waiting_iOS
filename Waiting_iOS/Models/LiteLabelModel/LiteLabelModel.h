//
//  LiteLabelModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiteLabelModel : NSObject

@property (nonatomic, strong) NSString      * labelID;          //标签ID (取id)
@property (nonatomic, strong) NSString      * name;             //标签名称
@property (nonatomic, strong) NSString      * status;           //标签状态 1 收集中 2 暂停 3 结束
@property (nonatomic, strong) NSString      * startAddress;     //
@property (nonatomic, strong) NSString      * mac;              //标签mac
@property (nonatomic, strong) NSString      * ctime;            //
@property (nonatomic, strong) NSString      * isDelete;         //
@property (nonatomic, strong) NSString      * netStatus;        //联网状态 1 未联网 2 已联网
@property (nonatomic, strong) NSString      * personNum;        //收集人数
@property (nonatomic, strong) NSString      * workTime;         //工作时长
@property (nonatomic, strong) NSString      * startLongitude;   //起始位置经度
@property (nonatomic, strong) NSString      * startLatitude;    //起始位置纬度

/*
 "id": 194,
 "accountId": 30,
 "deviceId": 9,//设备id
 "mac": "a0:9d:c1:7c:39:ca",//设备mac
 "name": "标签_20180710007",//标签名称
 "status": 3,//工作状态 1 收集中 2 暂停 3 结束
 "location": "",
 "startLongitude": "116.44355",//起始位置经度
 "startLatitude": "39.9219",//起始位置纬度
 "startLocation": "",
 "endLongitude": "",
 "endLatitude": "",
 "endLocation": "",
 "ctime": "2018-07-10 17:34:32",//创建时间
 "mtime": "2018-07-10 17:54:22",
 "recoveryTime": "2018-07-10 17:34:32",//暂停后点击继续时间
 "workTime": 749,//工作时长  秒为单位
 "isDelete": 1,//是否正常 1 正常 2 回收站
 "personNum": 0,//人群数
 "startAddress": "北京市朝阳区朝外街道北京市朝阳区档案馆北京市朝阳区人民政府",
 "endAddress": "北京市朝阳区朝外街道北京市朝阳区档案馆北京市朝阳区人民政府",
 "netStatus": 2//netStatus  1 未联网   2 已联网
 */
@end
