//
//  LitePhoneDetailCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteADsPhoneListModel.h"

@interface LitePhoneDetailCell : UITableViewCell

- (void)configWithData:(LiteADsPhoneListModel *)model;

@end
