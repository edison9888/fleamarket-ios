//
//  TBSDKPushCenterDataSubscribeUpdateDataModel.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-8.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSDKPushCenterModel.h"
#import "TBSDKPushCenterNewEngine.h"

/** 更新订阅配置的操作类
 */
@interface TBSDKPushCenterDataSubscribeUpdateDataModel : TBSDKPushCenterModel

/** 服务器返回值，更新状态描述对象 */
@property (nonatomic, strong) PushCenterSubscribeConfigObject                   *pushCenterSubscribeConfigObject;

/** 要更新的消息 */
@property (nonatomic, strong) NSArray                                           *msgTypes;

/** 淘系用户传入sid，非淘系用户传入nil */
@property (nonatomic, copy) NSString                                            *sessionID;

/** 淘系用户传入nil，非淘系用户传入用户登陆标示 */
@property (nonatomic, copy) NSString                                            *sToken;

/** 接收消息的控制状态 */
@property (nonatomic, unsafe_unretained) TBSDKPushCenterNewsSubscribeTypeStatus status;

@end