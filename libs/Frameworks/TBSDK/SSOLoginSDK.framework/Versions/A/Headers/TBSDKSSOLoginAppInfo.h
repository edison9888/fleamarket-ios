//
//  TBSDKSSOLoginAppInfo.h
//  LoginSDKDemo
//
//  Created by 亿刀 on 13-4-17.
//  Copyright (c) 2013年 yidao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBSDKSSOLoginAppInfo : NSObject<NSCoding>

/* app的名字 */
@property (nonatomic, strong) NSString                                          *appName;

/* app的版本号 */
@property (nonatomic, strong) NSString                                          *appVersion;

/* sso登陆时间 */
@property (nonatomic, strong) NSDate                                            *ssoLoginDate;

/* app的图标 */
@property (nonatomic, strong) UIImage                                           *appIconImage;

/* app的唯一标示 */
@property (nonatomic, strong) NSString                                          *bundleId;

/* 以当前app的信息初始化TBSDKSSOLoginAppInfo */
+ (TBSDKSSOLoginAppInfo *)currentAppInfo;

@end