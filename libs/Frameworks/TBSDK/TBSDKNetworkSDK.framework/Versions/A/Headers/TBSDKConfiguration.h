//
//  TBSDKConfiguration.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-1-28.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSDKAccountInfo;

//#define kDEVICEID_LENGTH_44 44 //deviceID的长度
//#define kDEVICEID_LENGTH_40 40 //deviceID的长度

@protocol TBSDKConfigurationPrivate <NSObject>

- (void)setTimestampOffset:(NSTimeInterval)offset;
- (void)setDeviceID:(NSString *)deviceID_;

@end

/** TBSDK环境设置 */
typedef enum
{
    TBSDKEnvironmentDebug =  1,     /**< 枚举，预发环境 */
    TBSDKEnvironmentDaily,          /**< 枚举，日常环境 */
    TBSDKEnvironmentRelease         /**< 枚举，正式环境 */
}TBSDKEnvironment;


/** 实体类存储着TBSDK的配置信息
 *
 * 实体类存储着TBSDK的配置信息，如果appkey，ttid等
 */
@interface TBSDKConfiguration : NSObject<TBSDKConfigurationPrivate>

//! 设置环境. PS:需要自己设置测试环境的APPKey Secret
@property (nonatomic, unsafe_unretained) TBSDKEnvironment                       environment;

//! 应用程序的 appKey
@property (nonatomic, strong) NSString                                          *appKey;

//! 应用程序的 appSecret
@property (nonatomic, strong) NSString                                          *appSecret;

//! 手机唯一识别码，TBSDK联网自动获取
@property (nonatomic, strong) NSString                                          *deviceID;

//! 软件版本号，比如 4.2.3      
@property (nonatomic, strong, readonly) NSString                                *appVersion;

//! 无线埋点的 ttid
@property (nonatomic, strong) NSString                                          *wapTTID;

//! TOP API 的请求地址，调用者可以设置自己的“topAPIURL”
@property (nonatomic, strong) NSString                                          *topAPIURL;

//! 无线 MTOP API 的请求地址，调用者可以设置自己的“wapAPIURL”
@property (nonatomic, strong) NSString                                          *wapAPIURL;

@property (nonatomic, strong) NSString                                          *wapAPISecurityURL;


//! 本地时间与服务器的时间差(秒)，TBSDK负责联网获取
@property (nonatomic, unsafe_unretained, readonly) NSTimeInterval               timestampOffset;

/** 老的deviceId。
 *
 *  如果是首次使用TBSDKNetworkSDK，并且app以前就有获取deviceId的逻辑，需传入oldDeviceId。因为TBSDKNetworkSDK在获取新的deviceId的时候需要老的deviceId。\n
 *  如果不是首次使用TBSDKNetworkSDK，oldDeviceId将被忽略
 *  详情请看：http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.sys.newDeviceId
 **/
@property (nonatomic, strong) NSString                                          *oldDeviceId;

/** 记录老的DeviceId */
@property (nonatomic, strong) NSString                                          *networkSDKOldDeviceId;

/** 存放了与登录相关信息，如sid，ecode等 */
@property (nonatomic, strong) TBSDKAccountInfo                                  *accountInfo;


+ (id)shareInstance;


@end
