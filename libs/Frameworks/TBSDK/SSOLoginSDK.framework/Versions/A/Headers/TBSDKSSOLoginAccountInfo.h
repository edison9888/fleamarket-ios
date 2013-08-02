//
//  TBSDKSSOLoginAccountInfo.h
//  LoginSDKDemo
//
//  Created by 亿刀 on 13-4-22.
//  Copyright (c) 2013年 yidao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSDKSSOLoginAppInfo;

@class TBSDKSSOLoginAppInfo;

/* 存储sso信息的实体类 */
@interface TBSDKSSOLoginAccountInfo : NSObject<NSCoding>

/* 用户名字 */
@property (nonatomic, strong) NSString                                          *accountName;

/* 哪个app保存的sso信息 */
@property (nonatomic, strong, readonly) TBSDKSSOLoginAppInfo                    *ssoTokenLoginAppInfo;

/* sso自动登陆令牌 */
@property (nonatomic, strong) NSString                                          *ssoToken;

/* ssoToken失效时间 */
@property (nonatomic, strong) NSDate                                            *ssotTokenInvalidDate;

/* SSOSDK版本号 */
@property (nonatomic, strong) NSString                                          *ssoLoginSDKVersion;

/* 包含了保存ssToken和使用ssoToken登录的app */
@property (nonatomic, strong) NSMutableArray                                    *ssoLoginAppInfoArray;


/* 获取SSOLoginAccountInfo,不包括过期的 */
+ (TBSDKSSOLoginAccountInfo *)getSSOLoginAccountInfo;

/* 获取SSOLoginAccountInfo,包括过期的 */
+ (TBSDKSSOLoginAccountInfo *)getSSOLoginAccountInfoCotainInvalid;

- (id)initWithAccountName:(NSString *)accountName
     ssoTokenLoginAppInfo:(TBSDKSSOLoginAppInfo *)ssoTokenLoginAppInfo
                 ssoToken:(NSString *)ssoToken
     ssotTokenInvalidDate:(NSDate *)ssotTokenInvalidDate
       ssoLoginSDKVersion:(NSString *)ssoLoginSDKVersion;

/* 删除SSOLoginAccountInfo */
+ (void)removeSSOLoginAccountInfo;

- (void)addSSOLoginAppInfo:(TBSDKSSOLoginAppInfo *)appInfo;
- (void)addUseSSOLoginAppInfo:(TBSDKSSOLoginAppInfo *)appInfo;
- (void)save;

@end