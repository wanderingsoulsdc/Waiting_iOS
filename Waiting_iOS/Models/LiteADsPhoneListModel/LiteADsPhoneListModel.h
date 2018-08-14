//
//  LiteADsPhoneListModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiteADsPhoneListModel : NSObject

@property (nonatomic, strong) NSString      * phone;            //电话
@property (nonatomic, strong) NSString      * reportSpend;      //花费
@property (nonatomic, strong) NSString      * startTime;        //最后开始时间
@property (nonatomic, strong) NSString      * talkTime;         //通话时长
@property (nonatomic, strong) NSString      * mark;             //标记类型 0未拨打 1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
@property (nonatomic, strong) NSString      * markInfo;         //标记内容
@property (nonatomic, strong) NSString      * cipherPhone;      //加密号码

/*
 "phone": "*******8670",
 "reportSpend": "0.08",
 "startTime": "2018-06-27 19:12:20",
 "talkTime": 1,
 "mark": 5,标记类型 0未拨打 1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
 "markInfo": "", //标记内容
 "cipherPhone": "DzZXNFwzVGhVZwE2AD0NMAc2UDYHZg=="
 */
@end
