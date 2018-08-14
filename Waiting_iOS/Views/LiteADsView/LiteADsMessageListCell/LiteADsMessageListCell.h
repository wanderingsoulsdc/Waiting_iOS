//
//  LiteADsMessageListCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteADsMessageListModel.h"

@interface LiteADsMessageListCell : UITableViewCell

- (void)configWithData:(LiteADsMessageListModel *)model;

@end
