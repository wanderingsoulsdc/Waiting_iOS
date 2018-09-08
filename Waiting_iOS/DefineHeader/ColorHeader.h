//
//  ColorHeader.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/25.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#ifndef ColorHeader_h
#define ColorHeader_h

//rgb色值
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0            alpha:1.0]
#define UIAlplaColorFromRGB(rgbValue,Alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:Alpha]


// App色值板
#define UIColorBlack           UIColorFromRGB(0x000000)
#define UIColorWhite           UIColorFromRGB(0xFFFFFF)
#define UIColorBlue            UIColorFromRGB(0x4895F2)      // 按钮主色
#define UIColorlightGray       UIColorFromRGB(0xDFDFDF)      // 按钮失效主色
#define UIColorBlueNav         UIColorFromRGB(0x4895F2)      // navigation主色
#define UIColorDrakBlackNav    UIColorFromRGB(0x96A4B2)      // navigation文字主色
#define UIColorDarkBlack       UIColorFromRGB(0x292B2C)      // 文字颜色
#define UIColorLine            UIColorFromRGB(0xEBEBEB)      // tableView分割线颜色
#define UIColorGray            UIColorFromRGB(0xC9D0D7)      // 浅色文字颜色
#define UIColorFooderText      UIColorFromRGB(0xCCCCCC)      // 上拉加载更多 文字颜色
#define UIColorError           UIColorFromRGB(0xFF735F)      // 错误颜色
#define UIColorAlert           UIColorFromRGB(0xFFA06D)      // 警告颜色


#define UIColorBackGround      UIColorFromRGB(0xF4F4F4)      // 页面背景颜色
#define UIColorClearColor      [UIColor clearColor]          // 透明色

#endif /* ColorHeader_h */
