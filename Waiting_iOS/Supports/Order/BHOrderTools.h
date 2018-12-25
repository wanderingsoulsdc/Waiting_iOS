//
//  BHOrderTools.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/4/3.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSNetWorkManager.h"

typedef enum : NSUInteger {
    BHOrderTypeAD,
    BHOrderTypePhone,
    BHOrderTypeMessage,
    BHOrderTypeWiFiAD,
} BHOrderType;

/**定义请求成功的block*/
typedef void(^requestSuccessOrderID)(NSString * orderID, NSDictionary * object);

/**定义请求失败的block*/
typedef void(^requestFailureOrderID)(NSString *errorMsg);

@interface BHOrderTools : NSObject

/**
 *  单利方法
 *
 *  @return 实例对象
 */
+(instancetype)shareManager;


- (void)requestOrderIdWithOrderType:(BHOrderType)type withSuccessBlock:(requestSuccessOrderID)successBlock withFailureBlock:(requestFailureOrderID)failureBlock;

@end
