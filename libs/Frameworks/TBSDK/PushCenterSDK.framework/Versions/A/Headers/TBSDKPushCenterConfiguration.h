//
//  TBSDKPushCenterConfiguration.h
//  PushCenterDemo
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-2-28.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PUBKEY_KEY_IN_USER_DEFALUT                  @"pubkey key in userDefault"
#define PUBKEY_DEVICEID_KEY_IN_USER_DEFALUT         @"deviceID of pubkey key in userDefalut"
#define PUSH_USER_TOKEN_KEY                         @"PUSH_USER_TOKEN_KEY"

/** PushCenterSDK的配置类 */
@interface TBSDKPushCenterConfiguration : NSObject

/** 以单例模式初始化 */
+ (id)shareInstance;

/** 调用网络接口，创建的deviceID */
@property (nonatomic, strong) NSString                                          *deviceID;

/** 一个pubkey对应一个DeviceID。如果DeviceID改变，pubkey也会失效，需要重新获取。 */
@property (nonatomic, strong) NSString                                          *pushkey;

/** 绑定API的返回值，解绑的使用。 */
@property (nonatomic, strong) NSString                                          *pushUserToken;

@end