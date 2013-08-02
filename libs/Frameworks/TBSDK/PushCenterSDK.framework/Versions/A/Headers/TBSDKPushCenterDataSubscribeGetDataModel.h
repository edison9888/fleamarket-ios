//
//  TBSDKPushCenterDataSubscribeGetDataModel.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-7.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSDKPushCenterModel.h"

///    接收消息的类型的枚举定义
typedef enum {
    TBSDKPushCenterNewsSubscribeTypeSubscribed = 0,                             ///< 枚举，认购
    TBSDKPushCenterNewsSubscribeTypeAll                                         ///< 枚举，全部
}TBSDKPushCenterNewsSubscribeType;

@class PushCenterSubscribeConfigObject;

/** 获取消息订阅配置的数据处理类
 */
@interface TBSDKPushCenterDataSubscribeGetDataModel : TBSDKPushCenterModel

/** 服务器返回的订阅配置数据对象 */
@property (nonatomic, strong)PushCenterSubscribeConfigObject                    *pushCenterSubscribeConfigObject;

/** 淘系用户传入sid，非淘系用户传入nil */
@property (nonatomic, strong) NSString                                          *sessionID;

/** 淘系用户传入nil，非淘系用户传入用户登陆标示 */
@property (nonatomic, strong) NSString                                          *sToken;

/** 接收消息的类型 */
@property (nonatomic, unsafe_unretained) TBSDKPushCenterNewsSubscribeType       pushCenterNewsSubscribeType;

@end