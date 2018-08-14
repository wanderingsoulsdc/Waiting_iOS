//
//  LiteADsMessageListModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiteADsMessageListModel : NSObject

@property (nonatomic, strong) NSString      * orderId;          //订单id
@property (nonatomic, strong) NSString      * orderName;        //短信名称
@property (nonatomic, strong) NSString      * successNum;       //成功数
@property (nonatomic, strong) NSString      * budget;           //短信预算
@property (nonatomic, strong) NSString      * reportSpend;      //实际花费
@property (nonatomic, strong) NSString      * status;           //订单状态 1 发送中，2 发送成功，3 发送失败，4 审核中，5 审核拒绝
@property (nonatomic, strong) NSString      * content;          //短信内容
@property (nonatomic, strong) NSString      * sign;             //签名
@property (nonatomic, strong) NSString      * auditTime;        //审核时间
@property (nonatomic, strong) NSString      * rejectReason;     //拒绝原因
@property (nonatomic, strong) NSString      * peopleNum;        //覆盖人数
@property (nonatomic, strong) NSString      * labelId;          //覆盖的标签id ,多个逗号分隔
@property (nonatomic, strong) NSString      * smsNum;           //单人次短信最大条数
@property (nonatomic, strong) NSString      * smsPrice;         //单价
@property (nonatomic, strong) NSString      * sendType;         //是否针对新增客户投放 1 否 2 是
@property (nonatomic, strong) NSString      * ctime;            //创建时间
@property (nonatomic, strong) NSString      * labelNum;         //覆盖的标签数
@property (nonatomic, strong) NSString      * smsTotal;         //短信条数
@property (nonatomic, strong) NSString      * remindersId;      //  0-未催审  否则-已催审
@property (nonatomic, strong) NSString      * mtime;            //更新时间(如催审 为催审时间)


@end
