//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBSocialShareConfig.h"
#import "WXApiObject.h"

@class TBSocialShareBaseModel;
@protocol WXApiDelegate;

@protocol TBSocialShareResultProtocol <NSObject>

@optional
- (void)socialShareSuccess:(TBSocialShareType)shareType result:(id)result;
- (void)socialShareFailed:(TBSocialShareType)shareType  error:(id)error;

- (void)loginSuccess:(TBSocialShareType)shareType;
- (void)loginFailed:(TBSocialShareType)shareType error:(NSError *)error;

- (void)logoutSuccess:(TBSocialShareType)shareType;

@end


@interface TBSocialShareToBase : NSObject

@property (nonatomic, weak) id<TBSocialShareResultProtocol> shareResultDelegate;

- (void)shareContent:(TBSocialShareBaseModel *)baseModel;

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate;

- (void)login;

- (void)logout;

- (BOOL)isLogin;

@end