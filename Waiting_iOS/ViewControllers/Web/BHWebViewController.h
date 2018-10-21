//
//  BHWebViewController.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/22.
//  Copyright © 2018年 BEHE. All rights reserved.
//
//  项目继承的父类

#import <UIKit/UIKit.h>
#import "BHLoadFailedView.h"

@interface BHWebViewController : UIViewController

@property (nonatomic , assign) BOOL             isHideNavi;

@property (nonatomic, strong) NSString  * url;
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) BHLoadFailedView       * loadFailedView;

- (void)loadWebView:(NSString *)url;
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request;

@end
