//
//  LiteADsSelectLabelCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteLabelModel.h"

@interface LiteADsSelectLabelCell : UITableViewCell

- (void)configWithData:(LiteLabelModel *)model;

- (void)cellBecomeSelected;

- (void)cellBecomeUnselected;

@end
