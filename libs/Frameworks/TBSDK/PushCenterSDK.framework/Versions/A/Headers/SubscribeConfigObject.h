//
//  SubscribeConfigObject.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-7.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! “mtop.push.subscribe.get”和“mtop.push.subscribe.update”返回值的数据模型类
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.subscribe.fetchSubscribeCfg_v4 
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.subscribe.updateSubscribeCfg_v4
 */
@interface SubscribeConfigObject : NSObject

/** 消息注册类型 */
@property (nonatomic, strong) NSString                                          *regType;

/** Push消息名，用于客户端展示 */
@property (nonatomic, strong) NSString                                          *name;

/** 消息订阅状态,true为已订阅，false为取消订阅 */
@property (nonatomic, unsafe_unretained) BOOL                                   subscribe;

//更新配置的返回结果

/** 错误代码
 *
 *  ER_BIZ_SUBSCRIBE_FAIL                   表示失败，
 *  ER_BIZ_SUBSCRIBE_NOT_EXIST              表示不存在，
 *  ER_BIZ_SUBSCRIBE_ILLEGAL_DEVICE_MSG     表示“不是设备消息”，
 *  ER_BIZ_SUBSCRIBE_UNKNOWN                表示未知，
 *  SUCCESS                                 表示成功
 */
@property (nonatomic, strong) NSString                                          *resultCode;

/** 对resultCode的错误描述 */
@property (nonatomic, strong) NSString                                          *resultMSG;

@end