//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBSocialShareConfig.h"

@protocol SinaWeiboRequestDelegate;
@protocol TBSocialShareResultProtocol;
@protocol WXApiDelegate;
@class TBSocialShareBaseModel;


@interface TBSocialShareManager : NSObject
+ (TBSocialShareManager *)instance;

/**
 用于微信跳转，微博sso认证

 @param url
 */
+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate;
- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate;

+ (void)registerApp;

/**
 发布内容到sns

 @param baseModel 需要发布的内容
 @param shareType 需要发布到哪个平台
 */
- (void)shareContent:(TBSocialShareBaseModel *)baseModel
           shareType:(TBSocialShareType)shareType
            delegate:(id<TBSocialShareResultProtocol>)delegate;

- (void)loginWithShareType:(TBSocialShareType)shareType
                  delegate:(id<TBSocialShareResultProtocol>)delegate;

- (void)logoutWithShareType:(TBSocialShareType)shareType
                   delegate:(id<TBSocialShareResultProtocol>)delegate;

- (BOOL)isLoginWithShareType:(TBSocialShareType)shareType;

- (BOOL)isWXAppInstalled;

@end