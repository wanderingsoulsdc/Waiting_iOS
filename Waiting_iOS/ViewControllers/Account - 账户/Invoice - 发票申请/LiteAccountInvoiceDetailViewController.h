//
//  LiteAccountInvoiceDetailViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"
#import "LiteAccountInvoiceModel.h"

@protocol LiteAccountInvoiceDetailDelegate <NSObject>

@optional
- (void)invoiceRecallSuccess:(LiteAccountInvoiceModel *)invoiceModel;

@end

@interface LiteAccountInvoiceDetailViewController : LiteBaseViewController

@property (nonatomic, strong) LiteAccountInvoiceModel      * invoiceModel;

@property (nonatomic , assign) id <LiteAccountInvoiceDetailDelegate> delegate;

@end
