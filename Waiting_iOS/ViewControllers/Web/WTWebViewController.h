//
//  WTWebViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/10/22.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHLoadFailedView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTWebViewController : UIViewController

@property (nonatomic , assign) BOOL                 isHideNavi;

@property (nonatomic , strong) NSString             * url;
@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;

@property (nonatomic , strong) BHLoadFailedView     * loadFailedView;

- (void)loadWebView:(NSString *)url;
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
