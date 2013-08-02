//
//  TBSDKSSOLoginEngine.h
//  LoginSDKDemo
//
//  Created by 亿刀 on 13-4-17.
//  Copyright (c) 2013年 yidao. All rights reserved.
//


/* sso总只存有一个账号的sso信息
 1、如果app是sso登录，账户注销的时候，必须注销sso信息
 2、一个app在sso中的信息只允许有一份
 3、如果app当前登录的用户和app在sso中的注册信息不一致，表示app已经注销了该用户
 4、自动登录的时候不应该写ssoToken
 */

#import <Foundation/Foundation.h>

#define TBSDKSSOLoginSDKVersion @"1.0"

@protocol TBSDKSSOLoginEngineDelegate;

@class TBSDKSSOLoginEngine;
@class TBSDKSSOLoginAccountInfo;
@class TBSDKErrorResponse;

typedef void (^TBSDKSSOLoginSuccessBlock)(TBSDKSSOLoginEngine *ssoLoginEngine, NSString *responseString);
typedef void (^TBSDKSSOLoginFailBlock)(TBSDKSSOLoginEngine *ssoLoginEngine, TBSDKErrorResponse *errorResponse, NSString *responseString);

/* SSO登陆模块的接口类 */
@interface TBSDKSSOLoginEngine : NSObject

/* 与sso模块交互的代理类 */
@property (nonatomic, unsafe_unretained) id<TBSDKSSOLoginEngineDelegate>        delegate;

/* 单例模式初始化 */
+ (TBSDKSSOLoginEngine *)shareInstance;

/* 开启sso */
- (void)startSSO;

/*  获取用户sso登录信息，包括ssoToken
 *
 *  @return  返回账号的sso信息。如果返回nil，表示没有sso信息或sso信息已经过期（14天）。
 *
 **/
- (TBSDKSSOLoginAccountInfo *)getSSOLoginAppInfo;

/*  进行ssoToken登录
 *
 *  @param successBlock 成功登录后回调block
 *  @param failBlock    登录失败后回调block
 **/
- (void)ssoLoginWithsuccessBlock:(TBSDKSSOLoginSuccessBlock)successBlock
                       failBlock:(TBSDKSSOLoginFailBlock)failBlock;

/*  注销sso信息
 *
 *  只有sso登录的APP才有权限注销
 */
- (void)logoutSSO;

/*  用户名和密码登录后，会获取sso信息，然后调用此接口保存。
 *  自动登录不要保存sso信息
 *
 *  @param accountName  nick
 *  @param ssoToken     登陆成功后返回的ssoToken
 */
- (void)saveAccountSSOInfoWithAccountName:(NSString *)accountName
                                 ssoToken:(NSString *)ssoToken;

@end

@protocol TBSDKSSOLoginEngineDelegate <NSObject>

@required

//当前登录的账户
- (NSString *)currentSSOLoginAccountName;

//是否在sso中已经注销
- (void)currentIsSSOLogout:(BOOL)isLogout;

@end