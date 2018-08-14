//
//  LitePhoneListCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/23.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteADsPhoneListModel.h"

@interface LitePhoneListCell : UITableViewCell

- (void)configWithData:(LiteADsPhoneListModel *)model;

@end
