//
//  MyAnimatedAnnotationView.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//  自定义BMKAnnotationView，用于显示动画

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MyAnimatedAnnotationView : BMKAnnotationView

@property (nonatomic, strong) NSMutableArray    * annotationImages;
@property (nonatomic, strong) UIImageView       * annotationImageView;

@end
