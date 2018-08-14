//
//  MyAnnotationView.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MyAnnotationView : BMKPinAnnotationView

@property (nonatomic ,strong) UILabel * titleLabel;
@property (nonatomic ,strong) UILabel * subTitleLabel;
@property (nonatomic ,strong) UIView  * tipView;

@end
