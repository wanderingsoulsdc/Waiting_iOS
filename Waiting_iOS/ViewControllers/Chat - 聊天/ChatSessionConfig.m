//
//  ChatSessionConfig.m
//  Waiting_iOS
//
//  Created by wander on 2018/10/17.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import "ChatSessionConfig.h"

@implementation ChatSessionConfig

- (NSArray<NSNumber *> *)inputBarItemTypes{
    //包含输入框、表情
    return @[@(NIMInputBarItemTypeTextAndRecord),
             @(NIMInputBarItemTypeEmoticon),
             ];
}

@end
