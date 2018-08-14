//
//  LiteAccountTransactionModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiteAccountTransactionModel : NSObject

@property (nonatomic, strong) NSString      * transactionId;        //交易ID
@property (nonatomic, strong) NSString      * transactionTitle;     //交易记录标题
@property (nonatomic, strong) NSString      * transactionMoney;     //交易金额
@property (nonatomic, strong) NSString      * transactionStatus;    //交易状态
@property (nonatomic, strong) NSString      * transactionTime;      //交易时间

@end
