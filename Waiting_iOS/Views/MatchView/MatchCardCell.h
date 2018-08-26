//
//  MatchCardCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/8/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHUserModel.h"

@interface MatchCardCell : UICollectionViewCell

- (void)configWithData:(BHUserModel *)model;

@end
