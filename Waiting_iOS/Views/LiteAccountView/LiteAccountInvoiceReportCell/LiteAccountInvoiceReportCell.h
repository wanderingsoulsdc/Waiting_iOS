//
//  LiteAccountInvoiceReportCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/21.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteAccountInvoiceModel.h"

@interface LiteAccountInvoiceReportCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath * indexPath;

- (void)configWithData:(LiteAccountInvoiceModel *)model;

@end
