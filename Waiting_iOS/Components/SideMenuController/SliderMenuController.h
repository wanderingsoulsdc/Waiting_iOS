//
//  SliderMenuController.h
//  SideMenuControllerDemo
//
//  Created by WJH on 17/2/22.
//  Copyright © 2017年 WJH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderMenuController : UIViewController


@property (nonatomic, strong, readonly) UIViewController *menuViewController;
@property (nonatomic, strong, readonly) UIViewController *contentViewController;
/**
 menuView未重叠的宽度
 */
@property (nonatomic, assign) CGFloat menuViewOverlapWidth;
/**
 
 */
@property (nonatomic, assign) CGFloat bezelWidth;
/**
 menuView滑出时contentView的缩放比例
 */
@property (nonatomic, assign) CGFloat contentViewScale;
/**
 menuView滑出时未遮住contentView的透明度
 */
@property (nonatomic, assign) CGFloat contentViewOpacity;
/**
 阴影透明度
 */
@property (nonatomic, assign) CGFloat shadowOpacity;
/**
 阴影模糊程度
 */
@property (nonatomic, assign) CGFloat shadowRadius;
/**
 阴影区域
 */
@property (nonatomic, assign) CGSize shadowOffset;
/**
 是否允许显示侧边栏
 */
@property (nonatomic, assign) BOOL panFromBezel;
/**
 是否允许从导航处滑出侧边栏
 */
@property (nonatomic, assign) BOOL panFromNavBar;
/**
 动画时间长
 */
@property (nonatomic, assign) CGFloat animationDuration;





/**
 初始化
 @param menuViewController 侧滑菜单
 @param contentViewController 主界面
 */
- (id)initWithMenuViewController:(UIViewController *)menuViewController
           contentViewController:(UIViewController *)contentViewController;

/**
 刷新contentViewController
 
 @param contentViewController 主界面
 @param closeMenu 是否关闭
 */
- (void)reloadContentViewController:(UIViewController *)contentViewController closeMenu:(BOOL)closeMenu;


/**
 重载MenuViewController
 
 @param menuViewController 侧边菜单
 @param closeMenu 是否关闭
 */
- (void)reloadMenuViewController:(UIViewController *)menuViewController closeMenu:(BOOL)closeMenu;


/**
 关闭侧边菜单
 */
- (void)closeMenu;


/**
 打开侧边菜单
 */
- (void)openMenu;

@end


@interface UIViewController (SliderMenuController)
- (SliderMenuController *)sideMenuController;
@end
