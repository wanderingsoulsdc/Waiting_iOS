//
//  LiteAccountTransactionCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/21.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteAccountTransactionModel.h"

typedef enum{
    TransactionCellTypeExpense,     //消费记录
    TransactionCellTypeRecharge,    //充值记录
}TransactionCellType;

@interface LiteAccountTransactionCell : UITableViewCell

@property (nonatomic , assign) TransactionCellType type;

- (void)configWithData:(LiteAccountTransactionModel *)model;

@end
