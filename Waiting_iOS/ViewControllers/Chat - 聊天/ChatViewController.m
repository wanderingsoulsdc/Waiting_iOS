//
//  ChatViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - ******* NIMSessionConfig 配置项 *******

- (id<NIMSessionConfig>)sessionConfig {
    //返回 nil，则使用默认配置，若需要自定义则自己实现
//    return nil;
    //返回自定义的 config，则使用此自定义配置
    return self.chatConfig;
}

#pragma mark - ******* Getter *******

- (ChatSessionConfig *)chatConfig{
    if (!_chatConfig) {
        _chatConfig = [[ChatSessionConfig alloc] init];
    }
    return _chatConfig;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
