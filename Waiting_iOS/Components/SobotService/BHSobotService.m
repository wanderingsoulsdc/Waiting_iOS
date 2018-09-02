//
//  BHSobotService.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/12/4.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHSobotService.h"
#import <SobotKit/SobotKit.h>
#import "BHUserModel.h"

@implementation BHSobotService

+ (instancetype)sharedInstance
{
    static BHSobotService *sobotService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(self){
            sobotService = [[self alloc] init];
        }
    });
    return sobotService;
}

- (void)startSoBotCustomerServiceWithViewController:(UIViewController *)viewController
{
    //  初始化配置信息
    ZCLibInitInfo *initInfo = [ZCLibInitInfo new];
    initInfo.appKey = kSoBotAppKey;
    initInfo.titleType = @"0";
    //    initInfo.customTitle = @"我的客服";
    initInfo.serviceMode = 0;
//    if ([[BHUserModel sharedInstance].permissionWcrd integerValue] == 1)
//    {
//        initInfo.serviceMode = 3;
//    }
//    else
//    {
//        initInfo.serviceMode = 2;
//    }
    
    //自定义用户参数
    initInfo.userId = [NSString stringWithFormat:@"zcb%@",[BHUserModel sharedInstance].userID];
    initInfo.nickName = kStringNotNull([BHUserModel sharedInstance].businessName) ? [NSString stringWithFormat:@"招-%@", [BHUserModel sharedInstance].businessName] : [NSString stringWithFormat:@"招-%@", [BHUserModel sharedInstance].mobile];
    initInfo.phone = [BHUserModel sharedInstance].mobile;
    
    // 自定义UI(设置背景颜色相关)
    ZCKitInfo *kitInfo = [ZCKitInfo new];
    //SDK页面中使用自定义的导航栏不在使用 系统的导航栏（隐藏）
    kitInfo.navcBarHidden = YES;
    // 评价完人工是否关闭会话
    kitInfo.isCloseAfterEvaluation = YES;
    // 点击返回是否触发满意度评价（符合评价逻辑的前提下）
    kitInfo.isOpenEvaluation = NO;
    // 是否显示转人工按钮
    kitInfo.isShowTansfer    = YES;
    // 如果isShowTansfer=NO 通过记录机器人未知说辞的次数，设置显示转人工按钮，默认1次;
    //    kitInfo.unWordsCount = @"2";
    // 是否显示语音按钮
    kitInfo.isOpenRecord = NO;
    
    /**
     *  自定义信息
     */
    // 顶部导航条标题文字 评价标题文字 系统相册标题文字 评价客服（立即结束 取消）按钮文字
    //    kitInfo.titleFont = [UIFont systemFontOfSize:30];
    
    // 返回按钮      输入框文字   评价客服是否有以下情况 label 文字  提价评价按钮
    //    kitInfo.listTitleFont = [UIFont systemFontOfSize:22];
    
    //没有网络提醒的button 没有更多记录label的文字    语音tipLabel的文字   评价不满意（4个button）文字  占位图片的lablel文字   语音输入时间label文字   语音输入的按钮文字
    //    kitInfo.listDetailFont = [UIFont systemFontOfSize:25];
    
    // 录音按钮的文字
    //    kitInfo.voiceButtonFont = [UIFont systemFontOfSize:25];
    // 消息提醒 （转人工、客服接待等）
    //    kitInfo.listTimeFont = [UIFont systemFontOfSize:22];
    
    // 聊天气泡中的文字
    //    kitInfo.chatFont  = [UIFont systemFontOfSize:22];
    
    // 聊天的背景颜色
    //    kitInfo.backgroundColor = [UIColor redColor];
    
    // 导航、客服气泡、线条的颜色
    kitInfo.customBannerColor  = UIColorFromRGB(0x5394E2);
    
    // 左边气泡的颜色
    //        kitInfo.leftChatColor = [UIColor redColor];
    
    // 右边气泡的颜色
    kitInfo.rightChatColor = UIColorFromRGB(0x5394E2);
    
    // 底部bottom的背景颜色
    //    kitInfo.backgroundBottomColor = [UIColor redColor];
    
    // 底部bottom的输入框线条背景颜色
    //    kitInfo.bottomLineColor = [UIColor redColor];
    
    // 提示气泡的背景颜色
    //    kitInfo.BgTipAirBubblesColor = [UIColor redColor];
    
    // 顶部文字的颜色
    //    kitInfo.topViewTextColor  =  [UIColor redColor];
    
    // 提示气泡文字颜色
    //        kitInfo.tipLayerTextColor = [UIColor redColor];
    
    // 评价普通按钮选中背景颜色和边框(默认跟随主题色customBannerColor)
    //        kitInfo.commentOtherButtonBgColor=[UIColor redColor];
    
    // 评价(立即结束、取消)按钮文字颜色(默认跟随主题色customBannerColor)
    //    kitInfo.commentCommitButtonColor = [UIColor redColor];
    
    //评价提交按钮背景颜色和边框(默认跟随主题色customBannerColor)
    //    kitInfo.commentCommitButtonBgColor = [UIColor redColor];
    
    //    评价提交按钮点击后背景色，默认0x089899, 0.95
    //    kitInfo.commentCommitButtonBgHighColor = [UIColor yellowColor];
    
    // 左边气泡文字的颜色
    //    kitInfo.leftChatTextColor = [UIColor redColor];
    
    // 右边气泡文字的颜色[注意：语音动画图片，需要单独替换]
    //    kitInfo.rightChatTextColor  = [UIColor redColor];
    
    // 时间文字的颜色
    //    kitInfo.timeTextColor = [UIColor redColor];
    
    // 客服昵称颜色
    //        kitInfo.serviceNameTextColor = [UIColor redColor];
    
    
    // 提交评价按钮的文字颜色
    //    kitInfo.submitEvaluationColor = [UIColor redColor];
    
    // 相册的导航栏背景颜色
    kitInfo.imagePickerColor = UIColorFromRGB(0x5394E2);
    
    // 相册的导航栏标题的文字颜色
    //    kitInfo.imagePickerTitleColor = [UIColor redColor];
    
    // 左边超链的颜色
    //        kitInfo.chatLeftLinkColor = [UIColor blueColor];
    
    // 右边超链的颜色
    //        kitInfo.chatRightLinkColor =[UIColor redColor];
    
    // 提示客服昵称的文字颜色
    //    kitInfo.nickNameTextColor = [UIColor redColor];
    // 相册的导航栏是否设置背景图片(图片来自SobotKit.bundle中ZCIcon_navcBgImage)
    //    kitInfo.isSetPhotoLibraryBgImage = YES;
    
    // 富媒体cell中线条的背景色
    //    kitInfo.LineRichColor = [UIColor redColor];
    
    //    // 语音cell选中的背景颜色
    //    kitInfo.videoCellBgSelColor = [UIColor redColor];
    //
    //    // 商品cell中标题的文字颜色
    //    kitInfo.goodsTitleTextColor = [UIColor redColor];
    //
    //    // 商品详情cell中摘要的文字颜色
    //    kitInfo.goodsDetTextColor = [UIColor redColor];
    //
    //    // 商品详情cell中标签的文字颜色
    //    kitInfo.goodsTipTextColor = [UIColor redColor];
    //
    //    // 商品详情cell中发送的文字颜色
    //    kitInfo.goodsSendTextColor = [UIColor redColor];
    
    // 发送按钮的背景色
    //        kitInfo.goodSendBtnColor = [UIColor yellowColor];
    
    // “连接中。。。”  button 的背景色和文字的颜色
//    kitInfo.socketStatusButtonBgColor  = UIColorFromRGB(0x5394E2);
    //    kitInfo.socketStatusButtonTitleColor = [UIColor redColor];
    
    
    //    kitInfo.notificationTopViewLabelFont = [UIFont systemFontOfSize:20];
    //    kitInfo.notificationTopViewLabelColor = [UIColor yellowColor];
    //    kitInfo.notificationTopViewBgColor = [UIColor redColor];
    
    // 评价 已解决 未解决的 颜色
    //    kitInfo.satisfactionSelectedBgColor = [UIColor redColor];
    //    kitInfo.satisfactionTextSelectedColor = [UIColor blueColor];
    
    /**
     // 自定义提示语相关设置
     // 用户超时下线提示语
     initInfo.customUserOutWord = _customUserOutWord.text;
     // 用户超时提示语
     initInfo.customUserTipWord = _customUserTipWord.text;
     // 人工客服提示语
     initInfo.customAdminTipWord = _customAdminTipWord.text;
     // 机器人欢迎语
     initInfo.customRobotHelloWord = _customRobotHelloWord.text;
     // 暂无客服在线说辞
     initInfo.customAdminNonelineTitle = _customAdminNonelineTitle.text;
     // 人工客服欢迎语
     initInfo.customAdminHelloWord  = _customAdminHelloWord.text;
     */
    
    // 测试模式
    [ZCSobot setShowDebug:NO];
    
    [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
    
    // 启动
//    [ZCSobot startZCChatView:kitInfo with:viewController target:nil pageBlock:^(ZCUIChatController *object, ZCPageBlockType type) {
//
//    } messageLinkClick:^(NSString *link) {
//
//    }];
    
    [ZCSobot startZCChatVC:kitInfo with:viewController target:nil pageBlock:^(ZCChatController *object, ZCPageBlockType type) {
        // 点击返回
        if(type==ZCPageBlockGoBack){
            NSLog(@"点击了关闭按钮");
        }
        
        // 页面UI初始化完成，可以获取UIView，自定义UI
        if(type==ZCPageBlockLoadFinish){
            
        }
    } messageLinkClick:nil];
}

@end
