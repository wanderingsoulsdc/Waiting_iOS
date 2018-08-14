//
//  LiteAccountInvoiceModel.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiteAccountInvoiceModel : NSObject

/*↓↓↓↓↓↓↓↓↓  申请发票  ↓↓↓↓↓↓↓↓↓↓↓*/

@property (nonatomic, strong) NSString   * key;                  //提交到服务器的key
@property (nonatomic, strong) NSString   * title;                //左边名称
@property (nonatomic, strong) NSString   * connect;              //右边内容
@property (nonatomic, strong) NSString   * placeholder;          //输入框内容
/*↑↑↑↑↑↑↑↑↑  申请发票  ↑↑↑↑↑↑↑↑↑↑*/
/*
 {
 "code": 200,
 "msg": "成功",
 "data": {
 "id": 1,
 "accountId": 24,
 "number": "1",//发票编号
 "invoiceType": 1,//发票类型 1增值税普通发票 2增值税专用发票
 "invoiceTitle": "1212",//发票抬头
 "credit": "12.00",//开票金额
 "type": 1,//开票人类型 1 企业 2 个人
 "bankName": "13",//开户行
 
 "identify": "13",//纳税人识别号
 "registerAddress": "",//注册地址
 "registerPhone": "",//注册电话
 "bankTaxpay": "",//银行纳税人证明
 "bankNumber": "13",//银行账户
 "consignee": "12",//收件人姓名
 "phone": "12",//收件人电话
 "address": "12",//收件人地址
 "applyTime": "2018-06-19 19:56:02",//申请时间
 "status": 4,//发票处理状态 1 待审核 2 已快递 3 审核拒绝 4 取消申请 5 审核通过
 "remark": "12",//备注内容
 "mtime": "2018-06-20 14:09:19",
 "reason": "13",//审核原因(备注)
 "expressName": "13",//快递名称
 "expressNumber": "13"//快递编号
 }
 }
 */
@property (nonatomic, strong) NSString      * accountId;            //用户ID
@property (nonatomic, strong) NSString      * id;                   //发票ID
@property (nonatomic, strong) NSString      * number;               //发票编号
@property (nonatomic, strong) NSString      * credit;               //发票开票金额

@property (nonatomic, strong) NSString      * invoiceType;          //发票类型 1增值税普通发票 2增值税专用发票
@property (nonatomic, strong) NSString      * invoiceTitle;         //发票抬头（公司或个人）
@property (nonatomic, strong) NSString      * type;                 //开票人类型 1 企业 2 个人
@property (nonatomic, strong) NSString      * applyTime;            //发票申请时间
@property (nonatomic, strong) NSString      * status;               //发票处理状态 1待审核 2已快递 3审核拒绝 4已撤销 5审核通过
@property (nonatomic, strong) NSString      * reason;               //审核原因(备注)


@property (nonatomic, strong) NSString      * mtime;                //发票状态备注内容
@property (nonatomic, strong) NSString      * remark;               //备注内容
@property (nonatomic, strong) NSString      * expressName;          //快递名称
@property (nonatomic, strong) NSString      * expressNumber;        //快递编号



@property (nonatomic, strong) NSString      * invoiceContent;       //发票项目 (目前是信息服务费)
@property (nonatomic, strong) NSString      * bankName;             //发票开户银行
@property (nonatomic, strong) NSString      * bankNumber;           //发票银行账号

@property (nonatomic, strong) NSString      * registerAddress;      //发票注册地址
@property (nonatomic, strong) NSString      * registerPhone;        //发票注册手机号
@property (nonatomic, strong) NSString      * identify;             //发票纳税人识别号
@property (nonatomic, strong) NSString      * bankTaxpay;           //发票银行纳税人证明链接
@property (nonatomic, strong) NSString      * invoiceTaxpayerProveStatus;//发票银行纳税人证明上传状态
@property (nonatomic, strong) NSString      * address;              //发票收件人地址
@property (nonatomic, strong) NSString      * phone;                //发票收件人电话
@property (nonatomic, strong) NSString      * consignee;            //发票收件人名字

@end


