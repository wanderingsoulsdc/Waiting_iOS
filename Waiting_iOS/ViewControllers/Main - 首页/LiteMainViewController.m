//
//  LiteMainViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/13.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteMainViewController.h"
#import "BHUserModel.h"
#import "FSNetWorkManager.h"
#import "ShowHUDTool.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>           //引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>             //引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>   //引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>       //地图信息搜索结果
#import "LiteShowBorderCardsView.h"
#import "LiteDeviceDetailViewController.h"
#import "LiteDeviceScanQRViewController.h"
#import "LiteDeviceWorkStatusViewController.h"
#import "LiteDeviceLabelListViewController.h"
#import "MyAnimatedAnnotationView.h"
#import "MyAnnotationView.h"

@interface LiteMainViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UINavigationControllerDelegate,LiteShowBorderCardsViewDelegate,LiteDeviceDetailEditSuccessDelegate,BMKGeoCodeSearchDelegate>
{
    BMKMapView          * _mapView;
    BMKLocationService  * _locService;
    
    BMKPointAnnotation  * _lockedScreenAnnotation;  //大头针
    MyAnnotationView    * _newAnnotationView;       //大头针上面视图
    
    BMKPointAnnotation  * _animatedAnnotation;      //动画大头针
    MyAnimatedAnnotationView * _animatedAnnotationView; //动画大头针视图
    
    BMKCircle           * _circle;                  //圆形覆盖物
    BMKPointAnnotation  * _centerAnnotation;        //(覆盖物中心点)
    BMKGeoCodeSearch    * _geocodesearch;           //地理编码主类，用来查询、返回结果信息
    NSString            * _geocodeSearchResultStr;  //经纬度解析结果
}

@property (nonatomic , strong) LiteShowBorderCardsView  * deviceCardView;

@property (nonatomic , strong) NSMutableArray           * deviceListArray;

@property (nonatomic , strong) UIButton                 * myLocationButton;
@property (nonatomic , assign) BOOL                     isRequestDeviceList;
//是否正在请求设备列表
@property (nonatomic , assign) NSInteger                     currentCardIndex;
//当前展示的卡片
@property (nonatomic , assign) BOOL                     isFirstLocation;
//是否首次定位
@property (nonatomic , assign) BOOL                     isCheckDeviceNetStatus;
//是否正在请求设备联网状态
@end

@implementation LiteMainViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.delegate = self;
    self.currentCardIndex = 0;
    _geocodeSearchResultStr = @"正在获取位置信息..";
    
    [self addAllSubViews];
    
    [self layoutSubviews];
    
    [self requestUserInfo];
    
    [self requestDeviceList];
    
    [self setupBaiduMap];
    
    [self SetMapNoDeviceOrNoWorking];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeviceSuccess:) name:kDeviceAddSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLabelSuccess:) name:kLabelAddSuccessNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestDeviceList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
#pragma mark - ******* UINavigationController Delegate *******
//// 将要显示控制器
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    // 判断要显示的控制器是否是自己
//    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
//    if (isSelfVC) {
//        [self.navigationController setNavigationBarHidden:isSelfVC animated:YES];
//    }
//}

#pragma mark - ******* UI About *******
//子视图添加操作
- (void)addAllSubViews{
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self.view addSubview:self.deviceCardView];
    [self.view addSubview:self.myLocationButton];
    
}
//视图布局
- (void)layoutSubviews{
    
}

#pragma mark - ******* Map About Private Method *******
//地图设置
- (void)setupBaiduMap{
    _mapView.zoomLevel = 19.5;          //放大等级
    if (IS_IPHONE5 || IS_IPhone6) {
        _mapView.zoomLevel = 19;        //放大等级
    }
    _mapView.rotateEnabled = NO;        //禁止旋转
    _mapView.overlookEnabled = NO;      //禁止俯仰角
    _mapView.zoomEnabledWithTap = NO;   //禁止用户缩放(双击或双指单击)
    _mapView.zoomEnabled = YES;         //用户多点缩放(双指)
    _mapView.showsUserLocation = NO;    //先关闭显示的定位图层

    //设置地图中心点在地图中的屏幕坐标位置
    [_mapView setMapCenterToScreenPt:CGPointMake(kScreenWidth/2,self.deviceCardView.top/2)];
    
    //定位服务
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;

    //反编码地理位置
    _geocodesearch= [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = self;
    
    //精度圈设置
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;    //不显示精度圈
    //param.isRotateAngleValid = NO;      //跟随态旋转角度是否生效
    param.locationViewImgName = @"bnavi_icon_location_fixed_new";
    [_mapView updateLocationViewWithParam:param];
    
}

//设置定位模式
- (void)mapChangeUserTrackingMode:(BMKUserTrackingMode)userTrackingMode{
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = userTrackingMode;//设置定位的状态
    /*
     目前为止，BMKMapView的定位模式(userTrackingMode)有4种分别是：
     BMKUserTrackingModeNone:
     普通定位模式，显示我的位置，我的位置图标和地图都不会旋转
     BMKUserTrackingModeFollow :
     定位跟随模式，我的位置始终在地图中心，我的位置图标会旋转，地图不会旋转
     BMKUserTrackingModeFollowWithHeading :
     定位罗盘模式，我的位置始终在地图中心，我的位置图标和地图都会跟着旋转
     BMKUserTrackingModeHeading：
     v4.1起支持，普通定位+定位罗盘模式，显示我的位置，我的位置始终在地图中心，我的位置图标会旋转，地图不会旋转。即在普通定位模式的基础上显示方向。
      */
    _mapView.showsUserLocation = YES;//显示定位图层
}

//添加大头针,并锁定在屏幕固定位置
- (void)mapAddAnnotation{
    //清除之前的覆盖物和标注
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    if (_lockedScreenAnnotation == nil) {
        _lockedScreenAnnotation = [[BMKPointAnnotation alloc]init];
        _lockedScreenAnnotation.isLockedToScreen = YES;
        _lockedScreenAnnotation.screenPointToLock = CGPointMake(kScreenWidth/2, self.deviceCardView.top/2);
//        _lockedScreenAnnotation.title = _geocodeSearchResultStr;
    }
    [_mapView addAnnotation:_lockedScreenAnnotation];
}

// 根据经纬度添加圆形覆盖物
- (void)mapAddCircleOverlayWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude radius:(CGFloat)radius{
    //清除之前的覆盖物和标注
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLLocationCoordinate2D coor;
    coor.latitude = latitude;
    coor.longitude = longitude;
    _circle = [BMKCircle circleWithCenterCoordinate:coor radius:radius];
    [_mapView addOverlay:_circle];
    
    _centerAnnotation = [[BMKPointAnnotation alloc]init];
    _centerAnnotation.isLockedToScreen = NO;
    _centerAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_centerAnnotation];
}

// 根据经纬度添加(动画大头针)
- (void)mapAddAnimationAnnotationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    //清除之前的覆盖物和标注
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    //动画大头针
    _animatedAnnotation = [[BMKPointAnnotation alloc] init];
    _animatedAnnotation.isLockedToScreen = NO;
    _animatedAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_animatedAnnotation];
    //中心点大头针
    _centerAnnotation = [[BMKPointAnnotation alloc]init];
    _centerAnnotation.isLockedToScreen = NO;
    _centerAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_centerAnnotation];
}

/* (工作状态)关闭实时定位 && 添加动画大头针 && 隐藏定位按钮*/
- (void)SetMapWorkingWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    _mapView.zoomLevel = 19.5;          //放大等级
    if (IS_IPHONE5 || IS_IPhone6) {
        _mapView.zoomLevel = 19;        //放大等级
    }
    [_locService stopUserLocationService];//停止定位
    _mapView.showsUserLocation = NO;//关闭显示的定位图层
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) animated:NO];
    
    [self mapAddAnimationAnnotationWithLatitude:latitude longitude:longitude];
    
    self.myLocationButton.hidden = YES;      //隐藏定位按钮
    
    _mapView.userInteractionEnabled = NO;
}

/* (暂停状态)关闭实时定位 && 添加圆形覆盖物,大头针 && 隐藏定位按钮*/
- (void)SetMapPauseWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    _mapView.zoomLevel = 19.5;          //放大等级
    if (IS_IPHONE5 || IS_IPhone6) {
        _mapView.zoomLevel = 19;        //放大等级
    }
    [_locService stopUserLocationService];//停止定位
    _mapView.showsUserLocation = NO;//关闭显示的定位图层

    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) animated:NO];
    
    [self mapAddCircleOverlayWithLatitude:latitude longitude:longitude radius:100];
    
    self.myLocationButton.hidden = YES;      //隐藏定位按钮
    
    _mapView.userInteractionEnabled = NO;
}
/* (创建状态<未工作状态>或者无设备状态)根据经纬度设置覆盖物 && 开启定位 && 开启定位按钮*/
- (void)SetMapNoDeviceOrNoWorking{
    [_locService startUserLocationService]; //开启定位
    //设置为定位跟随模式，我的位置始终在地图中心，我的位置图标会旋转，地图不会旋转
    [self mapChangeUserTrackingMode:BMKUserTrackingModeFollow];
    
    [self mapAddAnnotation];                //设置大头针
    
    self.myLocationButton.hidden = NO;      //开启定位按钮
    
    _mapView.userInteractionEnabled = YES;
}
#pragma mark - ******* Baidu SDK Delegate *******
/**
 *在地图View将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);

    [_mapView updateLocationData:userLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

/**
 *地图区域即将改变时会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    _newAnnotationView.tipView.hidden = YES; //移动过程中隐藏大头针头视图
}


/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!_isFirstLocation) {
        _isFirstLocation = YES;
        return;
    }
    _newAnnotationView.tipView.hidden = NO; //移动结束出现大头针头视图
    [self getReverseGeoCodeWithLocation:mapView.centerCoordinate];
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error;
{
    //addressDetail:层次化地址信息
    //address:地址名称
    //businessCircle:商圈名称
    // location:地址坐标
    // poiList:地址周边POI信息，成员类型为BMKPoiInfo
    if(error !=0) {
        NSLog(@"address:反地理编码搜索失败+++++");
    }else{
        NSLog(@"address:%@----%@-----%@",result.addressDetail, result.address,result.sematicDescription);
        //竞园国际影像产业基地内,竞园-27A内0米
        NSArray *array = [result.sematicDescription componentsSeparatedByString:@","];
        NSString *resultStr = @"";
        if (array.count > 1) {
            resultStr = array.lastObject;
        }else{
            resultStr = result.sematicDescription;
        }
        
        // 准备对象
        NSString *regExpString  = @"[0-9]+米"; //用于匹配的正则
        NSString *replaceString = @"";         //替换用的字符串
        _geocodeSearchResultStr =
            [resultStr stringByReplacingOccurrencesOfString:regExpString
                                                     withString:replaceString
                                                        options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                          range:NSMakeRange (0, resultStr.length)];
        
        
//        _lockedScreenAnnotation.title = _geocodeSearchResultStr;
        _newAnnotationView.titleLabel.text = _geocodeSearchResultStr;
    }
}

// 根据anntation生成对应的View(自定义大头针)
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        if (annotation == _lockedScreenAnnotation){
            NSString *AnnotationViewID = @"lockedScreenAnnotation";
            
            _newAnnotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            _newAnnotationView.pinColor = BMKPinAnnotationColorRed;
            _newAnnotationView.animatesDrop = NO;    // 从天上掉下效果
            _newAnnotationView.draggable = NO;       // 设置不可拖拽
            _newAnnotationView.annotation = annotation;
            _newAnnotationView.image = [UIImage imageNamed:@"main_map_annotation"];   //把大头针换成别的图片            
            return _newAnnotationView;
            
        }else if (annotation == _centerAnnotation){
            NSString *AnnotationViewID = @"centerAnnotation";
            BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
            if (annotationView == nil) {
                annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
                // 设置颜色
                annotationView.pinColor = BMKPinAnnotationColorRed;
                // 设置可拖拽
                annotationView.draggable = NO;
                //自定义大头针图案
                annotationView.image = [UIImage imageNamed:@"main_map_center_annotation"];
                annotationView.centerOffset = CGPointMake(0.5, 0.5);
                // 从天上掉下效果
                annotationView.animatesDrop = NO;
            }
            return annotationView;
        }else if (annotation == _animatedAnnotation){ //动画annotation
            NSString *AnnotationViewID = @"AnimatedAnnotation";
            MyAnimatedAnnotationView *annotationView = nil;
            if (annotationView == nil) {
                annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            }
            NSMutableArray *images = [NSMutableArray array];
            for (int i = 0; i < 60; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"animation_%d.png", i]];
                [images addObject:image];
            }
            annotationView.annotationImages = images;
            return annotationView;
        }
    }
    return nil;
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isEqual:_circle])
    {
        BMKCircleView * circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor alloc] initWithRed:170/255.0 green:199/255.0 blue:232/255.0 alpha:0.5];
        circleView.strokeColor = [[UIColor alloc] initWithRed:170/255.0 green:199/255.0 blue:232/255.0 alpha:0.5];
        return circleView;
    }
    return nil;
}

#pragma mark - ******* Notification *******

- (void)addDeviceSuccess:(NSNotification *)noti{
    NSString *string = (NSString *)noti.object;
    [[ShowHUDTool shareManager] showAlertWithCustomImage:@"login_register_success" title:@"设备添加成功" message:string];
}

- (void)addLabelSuccess:(NSNotification *)noti{
    LiteDeviceModel *deviceModel = (LiteDeviceModel *)noti.object;
    LiteDeviceLabelListViewController *listVC = [[LiteDeviceLabelListViewController alloc] init];
    listVC.deviceModel = deviceModel;
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - ******* Private Method *******

//发起反向地理编码检索
- (void)getReverseGeoCodeWithLocation:(CLLocationCoordinate2D)pt
{
    //反编码地理位置
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeocodeSearchOption.location= pt;
    if([_geocodesearch reverseGeoCode:reverseGeocodeSearchOption]){
        NSLog(@"反geo检索发送成功");
    }else{
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark - ******* Action About *******

//定位按钮
- (void)myLocationButtonAction:(UIButton *)button{
    [self mapChangeUserTrackingMode:BMKUserTrackingModeFollow];
    _newAnnotationView.tipView.hidden = YES; //定位自己过程中隐藏大头针头视图
}

#pragma mark - ******* Common Delegate *******

- (void)CardsViewAction:(CardsCellActionType)type deviceModel:(LiteDeviceModel *)deviceModel{
    switch (type) {
        case ActionTypeAddDevice:
        {
            NSLog(@"首页:cardView:点击cell里的添加按钮");
            LiteDeviceScanQRViewController *vc = [[LiteDeviceScanQRViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case ActionTypeDeviceName:
        {   
            NSLog(@"首页:cardView:点击cell里的设备名称  设备ID:%@",deviceModel.deviceId);
            for (LiteDeviceModel *model in self.deviceListArray) {
                if ([model isEqual:deviceModel]) {
                    LiteDeviceDetailViewController *detailVC = [[LiteDeviceDetailViewController alloc] init];
                    detailVC.title = model.deviceName;
                    detailVC.deviceId = model.deviceId;
                    detailVC.delegate = self;
                    detailVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:detailVC animated:YES];
                    return;
                }
            }
            break;
        }
        case ActionTypeLabelNum:
        {
            NSLog(@"首页:cardView:点击cell里的已创建标签按钮 设备ID:%@",deviceModel.deviceId);
            LiteDeviceLabelListViewController *listVC = [[LiteDeviceLabelListViewController alloc] init];
            listVC.title = [NSString stringWithFormat:@"%@的标签",deviceModel.deviceName];
            listVC.deviceModel = deviceModel;
            listVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:listVC animated:YES];
            break;
        }
        case ActionTypeBottom:
        {
            NSLog(@"首页:cardView:点击cell里的创建标签按钮 设备ID:%@",deviceModel.deviceId);
            CLLocationCoordinate2D centerCoordinate = _mapView.centerCoordinate;
            
            LiteDeviceWorkStatusViewController *deviceWorkStatusVC = [[LiteDeviceWorkStatusViewController alloc] init];
            deviceWorkStatusVC.deviceModel = deviceModel;
            
            if ([deviceModel.sign isEqualToString:@"1"]) {//工作状态 1 正在工作中 2 已暂停工作 3 创建标签
                deviceWorkStatusVC.coordinate = CLLocationCoordinate2DMake([deviceModel.startLatitude doubleValue], [deviceModel.startLongitude doubleValue]);
                deviceWorkStatusVC.workType = DeviceStatusTypeWorking;
                deviceWorkStatusVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:deviceWorkStatusVC animated:YES];
            }else if ([deviceModel.sign isEqualToString:@"2"]) {
                deviceWorkStatusVC.coordinate = CLLocationCoordinate2DMake([deviceModel.startLatitude doubleValue], [deviceModel.startLongitude doubleValue]);
                deviceWorkStatusVC.workType = DeviceStatusTypeWorkPause;
                deviceWorkStatusVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:deviceWorkStatusVC animated:YES];
            }else if ([deviceModel.sign isEqualToString:@"3"]) {
    
                //请求设备联网状态
                if (self.isCheckDeviceNetStatus) {
                    return;
                }
                WEAKSELF
                self.isCheckDeviceNetStatus = YES;
                [FSNetWorkManager requestWithType:HttpRequestTypeGet
                                    withUrlString:kApiDeviceGetNetStatus
                                    withParaments:@{@"mac":deviceModel.mac}
                                 withSuccessBlock:^(NSDictionary *object) {
                                     
                                     if (NetResponseCheckStaus)
                                     {
                                         NSLog(@"请求成功");
                                         NSDictionary *dic = object[@"data"];
                                         NSString *netStatus = [dic stringValueForKey:@"netStatus" default:@""];
                                         if ([netStatus isEqualToString:@"1"]) { //未联网
                                             [ShowHUDTool showBriefAlert:@"设备已断网，请联网重试或结束工作！"];
                                         }else{ //已联网,进行下一步操作
                                             deviceWorkStatusVC.coordinate = centerCoordinate;
                                             deviceWorkStatusVC.workType = DeviceStatusTypeWorkNone;
                                             deviceWorkStatusVC.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:deviceWorkStatusVC animated:YES];
                                         }
                                         self.isCheckDeviceNetStatus = NO;
                                     }
                                     else
                                     {
                                         [ShowHUDTool showBriefAlert:NetResponseMessage];
                                         self.isCheckDeviceNetStatus = NO;
                                     }
                                 } withFailureBlock:^(NSError *error) {
                                     NSLog(@"error is:%@", error);
                                     self.isCheckDeviceNetStatus = NO;
                                     [ShowHUDTool showBriefAlert:NetRequestFailed];
                                 }];
                
            }
            break;
        }
        default:
            break;
    }
}
//根据得到的卡片index 刷新地图状态
- (void)CardsViewCurrentItem:(NSInteger)index{
    self.currentCardIndex = index;
    //index包含添加设备卡片,即index最大的数是添加设备
    NSLog(@"当前item是%ld",(long)index);
    if (index == self.deviceListArray.count) { //添加设备卡片
        [self SetMapNoDeviceOrNoWorking];
    }else{
        LiteDeviceModel *model = self.deviceListArray[index];
        if ([model.sign isEqualToString:@"3"]) {    //创建标签
            [self SetMapNoDeviceOrNoWorking];
        }else if([model.sign isEqualToString:@"2"]){  //暂停工作
            [self SetMapPauseWithLatitude:[model.startLatitude doubleValue] longitude:[model.startLongitude doubleValue]];
        }else if([model.sign isEqualToString:@"1"]){  //正在工作
            [self SetMapWorkingWithLatitude:[model.startLatitude doubleValue] longitude:[model.startLongitude doubleValue]];
        }
    }
}

//设备编辑成功刷新设备列表
- (void)LiteDeviceDetailEditSuccess{
    [self requestDeviceList];
}

#pragma mark - ******* Request About *******

//请求用户详情
- (void)requestUserInfo
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiGetUserInfo
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

//请求设备列表
- (void)requestDeviceList
{
    WEAKSELF
    if (self.isRequestDeviceList) { //如果正在请求中,不做操作
        return;
    }
    self.isRequestDeviceList = YES;
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceList
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             
                             [BHUserModel sharedInstance].deviceNum = [dataDic stringValueForKey:@"total" default:@""];
                             
                             NSArray * array = dataDic[@"list"];
                             if (array.count > 0)
                             {
                                 NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteDeviceModel * model = [[LiteDeviceModel alloc] init];
                                     model.deviceId = [dict stringValueForKey:@"id" default:@""];
                                     model.deviceName = [dict stringValueForKey:@"deviceName" default:@""];
                                     model.mac = [dict stringValueForKey:@"mac" default:@""];
                                     model.netStatus = [dict stringValueForKey:@"netStatus" default:@""];
                                     model.labelId = [dict stringValueForKey:@"labelId" default:@""];
                                     model.labelNum = [dict stringValueForKey:@"labelNum" default:@""];
                                     model.labelTodayNum = [dict stringValueForKey:@"labelTodayNum" default:@""];
                                     model.personNum = [dict stringValueForKey:@"personNum" default:@""];
                                     model.sign = [dict stringValueForKey:@"sign" default:@""];
                                     model.startLatitude = [dict stringValueForKey:@"startLatitude" default:@""];
                                     model.startLongitude = [dict stringValueForKey:@"startLongitude" default:@""];
                                     [tempArr addObject:model];
                                 }
                                 
                                 weakSelf.deviceCardView.dataArr = tempArr;
                                 
                                 weakSelf.deviceListArray = [tempArr copy];
                                 
                                 [weakSelf CardsViewCurrentItem:weakSelf.currentCardIndex];
                             }
                             weakSelf.deviceCardView.hidden = NO;
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         
                         weakSelf.isRequestDeviceList = NO;
                         
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         weakSelf.isRequestDeviceList = NO;
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - ******* Getter *******

- (LiteShowBorderCardsView *)deviceCardView{
    if (!_deviceCardView) {
        NSInteger CardViewH = 230;
        if (IS_IPhoneX || IS_IPhone6plus) {
            CardViewH = 230;
        }else if(IS_IPHONE5){
            CardViewH = 230;
        }
        _deviceCardView = [[LiteShowBorderCardsView alloc] initWithFrame:CGRectMake(0, kScreenHeight - CardViewH - 16 - 49 - SafeAreaBottomHeight, kScreenWidth, CardViewH)];
        _deviceCardView.delegate = self;
        _deviceCardView.dataArr = @[];
        _deviceCardView.hidden = YES;
    }
    return _deviceCardView;
}

- (NSMutableArray *)deviceListArray
{
    if (!_deviceListArray)
    {
        _deviceListArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceListArray;
}

- (UIButton *)myLocationButton{
    if (!_myLocationButton) {
        NSInteger buttonWH = 38;
        NSInteger buttonMargin = 12;
        _myLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - buttonMargin - buttonWH, kScreenHeight - 230 - 16 - 49 - SafeAreaBottomHeight - buttonMargin - buttonWH, buttonWH, buttonWH)];
        _myLocationButton.hidden = YES;
        [_myLocationButton setImage:[UIImage imageNamed:@"main_map_my_location"] forState:UIControlStateNormal];
        [_myLocationButton addTarget:self action:@selector(myLocationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myLocationButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
