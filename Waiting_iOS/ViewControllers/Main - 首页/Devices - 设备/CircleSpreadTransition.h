//
//  CircleSpreadTransition.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/9.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CircleSpreadTransitionType) {
    CircleSpreadTransitionTypePresent = 0,
    CircleSpreadTransitionTypeDismiss
};

@interface CircleSpreadTransition : NSObject<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

@property (nonatomic, assign) CircleSpreadTransitionType type;

+ (instancetype)transitionWithTransitionType:(CircleSpreadTransitionType)type;
- (instancetype)initWithTransitionType:(CircleSpreadTransitionType)type;
@end
