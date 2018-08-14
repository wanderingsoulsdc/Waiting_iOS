//
//  FSNetWorkError.m
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/28.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import "FSNetWorkError.h"

@implementation FSNetWorkError

/**
 *  根据errorCode返回错误信息
 *
 *  @param errorCode 错误码
 *
 *  @return 错误码对于的提示信息
 */
+ (NSString *)checkNetWorkErrorCode:(NSNumber *)errorCode
{
    switch ([errorCode integerValue]) {
        case 100101:
            return @"请求接口过于频繁，请稍后再试";
        case 100102:
            // 短信接口抛出来的错误
            return @"该接口不存在";
        case 100103:
            return @"服务不可用";
        case 100104:
            return @"权限错误";
        case 100201:
            return @"您尚未登录";
        case 100202:
            return @"token已过期，请重新登录";
        case 100203:
            return @"token已过期，请重新登录";
        case 100204:
            return @"您的账号已在其他设备登录";
        case 100301:
            return @"请求参数错误";
        case 100302:
            return @"验证码错误";
        case 100303:
            return @"验证码错误";
        case 100304:
            return @"数据库操作错误";
        case 100305:
            return @"签名验证失败";
        case 100307:
            return @"没有数据";
        case 200101:
            return @"用户名或密码错误";
        case 200102:
            return @"登录过于频繁，请稍后再试";
        case 200103:
            return @"该账号已停用";
        case 200104:
            return @"密码过于简单，请更换密码";
        case 200105:
            return @"密码应为6-18位数字、字母或下划线组成";
        case 200106:
            return @"邮箱格式错误";
        case 200107:
            return @"密码应为6-18位数字、字母或下划线组成";
        case 200108:
            return @"密码不能为空";
        case 200109:
            return @"邮箱不能为空";
        case 200110:
            return @"两次密码不一致";
        case 200111:
            return @"手机号不能为空";
        case 200112:
            return @"手机号格式错误";
        case 200113:
            return @"url格式错误";
        case 200114:
            return @"联系人不能为空";
        case 200115:
            return @"联系人名称错误";
        case 200116:
            return @"手机号错误";
        case 200117:
            return @"省份不能为空";
        case 200118:
            return @"城市不能为空";
        case 200119:
            return @"省份id错误";
        case 200120:
            return @"城市id错误";
        case 200121:
            return @"备注最多80个字符";
        case 200122:
            return @"url不能为空";
        case 200201:
            return @"用户无访问权限";
        case 200202:
            return @"添加或更新用户权限不能超过200个";
        case 200301:
            return @"用户不存在";
        case 200401:
            return @"支付信息不存在";
        case 200402:
            return @"支付日志信息不存在";
        case 200403:
            return @"只能查看自己的支付信息";
        case 200501:
            return @"绑定的again账户不存在";
        case 200502:
            return @"不能删除不属于自己或未绑定的again账户";
        case 200503:
            return @"不能解绑不属于自己或未绑定的again账户";
        case 200504:
            return @"不能重复绑定账号";
        case 200601:
            return @"不能重复绑定ftp账号";
        case 200701:
            return @"只能查看自己购买的标签";
        case 200702:
            return @"该用户已被禁用";
        case 200801:
            return @"只能查看属于自己部门的站点信息";
        case 200802:
            return @"该站点已存在";
        case 200803:
            return @"站点添加失败";
        case 200804:
            return @"当前站点该事件已存在";
        case 200805:
            return @"当前站点不存在";
        case 200806:
            return @"站点事件已达上限";
        case 200807:
            return @"找不到站点id对应的事件或站点事件达到上限";
        case 200808:
            return @"时间格式错误，不能超过30天";
        case 200809:
            return @"时间格式错误";
        case 200901:
            return @"事业部添加失败";
        case 200902:
            return @"事业部已存在";
        case 200903:
            return @"事业部不存在";
        case 200904:
            return @"品牌添加失败";
        case 200905:
            return @"品牌不存在";
        case 200906:
            return @"产品线添加失败";
        case 300101:
            return @"没有媒体数据";
        case 300102:
            return @"没有点位数据";
        case 300103:
            return @"图标维度不能为空";
        case 101100:
            return @"参数错误";
        case 101101:
            return @"仅支持GET请求";
        case 101102:
            return @"仅支持POST请求";
        case 101103:
            return @"仅支持PUT请求";
        case 101104:
            return @"仅支持DELETE请求";
        case 201100:
            return @"任务id不存在";
        case 201101:
            return @"layer错误，不是json格式";
        case 201102:
            return @"name错误";
        case 201103:
            return @"site错误";
        case 201104:
            return @"查询日期不能超过30天";
        case 201105:
            return @"查询日期不能超过30天";
        case 201200:
            return @"广告不存在";
        case 201201:
            return @"广告存在";
        case 400101:
            return @"角色rule获取失败";
        case 400102:
            return @"获取角色名称异常";
        case 400103:
            return @"编辑角色信息异常";
        case 400104:
            return @"用户select rule no data";
        case 400105:
            return @"没有事业部数据";
        case 400106:
            return @"没有品牌数据";
        case 400107:
            return @"没有产品线数据";
        case 400108:
            return @"自定义角色没有rule数据";
        case 400109:
            return @"用户已存在";
        case 400110:
            return @"角色名已存在";
        case 400111:
            return @"该角色下有用户,禁止删除";
        case 500101:
            return @"该监控规则已经存在";
        case 500102:
            return @"起止时间错误";
            
        default:
            return [NSString stringWithFormat:@"系统错误，错误码：%@",errorCode];
            break;
    }
    return @"";
}

@end
