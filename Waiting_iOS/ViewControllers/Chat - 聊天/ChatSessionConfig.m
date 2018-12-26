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
             @(NIMInputBarItemTypeMore),
             ];
}

- (NSArray *)mediaItems
{
//    NSArray *defaultMediaItems = [NIMKit sharedKit].config.defaultMediaItems;
    
    NIMMediaItem * audioChat =  [NIMMediaItem item:@"onTapMediaItemAudioChat:"
                                      normalImage:[UIImage imageNamed:@"chat_media_voice"]
                                    selectedImage:[UIImage imageNamed:@"chat_media_voice"]
                                            title:ZBLocalized(@"Voice Call", nil)];
    
    NIMMediaItem * videoChat =  [NIMMediaItem item:@"onTapMediaItemVideoChat:"
                                      normalImage:[UIImage imageNamed:@"chat_media_video"]
                                    selectedImage:[UIImage imageNamed:@"chat_media_video"]
                                            title:ZBLocalized(@"Video Call", nil)];
    
    NSArray *items = @[audioChat,videoChat];
    
    return items;
    
}

@end
