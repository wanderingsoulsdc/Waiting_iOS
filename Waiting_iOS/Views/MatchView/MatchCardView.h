//
//  MatchCardView.h
//  Waiting_iOS
//
//  Created by wander on 2018/8/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHUserModel.h"

@protocol MatchCardDelegate <NSObject>

@optional
//当前展示的item是第几个
- (void)CardsViewCurrentItem:(NSInteger)index;
//点击事件传递
- (void)CardsViewActionWithModel:(BHUserModel *)model;

@end

@interface MatchCardView : UIView

@property(nonatomic, copy) NSArray *dataArr;

@property (nonatomic , assign) id <MatchCardDelegate> delegate;

@end
