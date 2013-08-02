//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 下午2:47.
//


#import <TBSDK/TBSDKConfiguration.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <TBSDK/TBSDKSSOLoginEngine.h>
#import <TaobaoRemoteObject/TopHandler.h>
#import <UserTrack/UT.h>
#import "FMLoginService.h"
#import "TBSDKLoginEngine.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "TBSDKAccountInfo.h"
#import "TBSDKErrorResponse.h"
#import "ClientApiHandler.h"
#import "Mtop3Handler.h"
#import "FMPushService.h"
#import "NSString+Helper.h"

#define NO_NEED_SAVE_SSO @"NO_NEED_SAVE_SSO"

@implementation FMLoginResponse
@end

@implementation FMLoginService {

}

+ (TBSDKLoginSuccessBlock)getLoginSuccessBlock:(FMLoginResponseBlock)response on:(dispatch_queue_t)queue {
    return ^(TBSDKLoginEngine *loginEngine, NSString *responseString) {
        dispatch_async(queue, ^{
            TBSDKConfiguration *configuration = [TBSDKConfiguration shareInstance];
            TBSDKAccountInfo *accountInfo = configuration.accountInfo;
            NSString *nick = accountInfo.nick;
            FMUser *user = [FMApplication instance].loginUser;
            user.id = accountInfo.userId;
            user.name = nick;
            user.sid = accountInfo.sid;
            user.topSession = accountInfo.topSession;
            user.autoLoginToken = accountInfo.loginToken;
            user.ecode = accountInfo.ecode;
            user.cookies = accountInfo.cookies;
            user.isLogin = YES;


            [[FMApplication instance] asyncSaveToPreference];

            [ClientApiHandler instance].sid = accountInfo.sid;
            [Mtop3Handler instance].sid = accountInfo.sid;
            [TopHandler instance].topSession = accountInfo.topSession;

            [FMPushService updateDevice];

            if (![loginEngine.userInfo objectForKey:NO_NEED_SAVE_SSO]) {
                [[TBSDKSSOLoginEngine shareInstance]
                                      saveAccountSSOInfoWithAccountName:nick
                                                               ssoToken:loginEngine.ssoToken];
            }

            if (response) {
                FMLoginResponse *loginResponse = [[FMLoginResponse alloc] init];
                loginResponse.isSuccess = YES;
                loginResponse.responseString = responseString;
                response(loginResponse);
            }
            TBMBGlobalSendNotificationForSEL(@selector($$loginSuccess:));
            dispatch_async(dispatch_get_main_queue(), ^{
                [UT updateUserAccount:nick];
            }
            );
        }
        );
    };
}

+ (TBSDKLoginFailBlock)getLoginFailedBlock:(FMLoginResponseBlock)response  on:(dispatch_queue_t)queue {
    return ^(TBSDKLoginEngine *loginEngine, TBSDKErrorResponse *errorResponse, NSString *responseString) {
        dispatch_async(queue, ^{
            FMUser *user = [FMApplication instance].loginUser;
            user.isLogin = NO;
            if (response) {
                FMLoginResponse *loginResponse = [[FMLoginResponse alloc] init];
                loginResponse.isSuccess = NO;
                loginResponse.responseString = responseString;
                loginResponse.errorString = loginEngine.errorResponse.msg;
                response(loginResponse);
            }
            TBMBGlobalSendNotificationForSEL(@selector($$loginFailed:));
        }
        );
    };
}

+ (TBSDKLoginNeedCheckCodeBlock)getLoginNeedCheckCodeBlock:(FMLoginResponseBlock)response  on:(dispatch_queue_t)queue {
    return ^(TBSDKLoginEngine *loginEngine, NSString *checkCodeId, NSString *checkCodeURL) {
        dispatch_async(queue, ^{
            FMUser *user = [FMApplication instance].loginUser;
            user.isLogin = NO;
            if (response) {
                FMLoginResponse *loginResponse = [[FMLoginResponse alloc] init];
                loginResponse.isSuccess = NO;
                loginResponse.needCheckCode = YES;
                loginResponse.errorString = loginEngine.errorResponse.msg;
                loginResponse.checkCodeId = checkCodeId;
                loginResponse.checkCodeUrl = checkCodeURL;
                response(loginResponse);
            }
            TBMBGlobalSendNotificationForSEL(@selector($$loginFailed:));
        }
        );
    };
}

+ (void)loginWithUserName:(NSString *)userName
              AndPassword:(NSString *)password
           AndCheckCodeId:(NSString *)checkCodeId
             AndCheckCode:(NSString *)checkCode
            loginResponse:(FMLoginResponseBlock)callback {
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
    [loginEngine loginWithUsername:userName
                          password:password
                       checkCodeId:checkCodeId
                         checkCode:checkCode
                               syn:NO
                          userInfo:nil
            needMainThreadCallBack:NO
                      successBlock:[self getLoginSuccessBlock:callback on:currentQueue]
                         failBlock:[self getLoginFailedBlock:callback on:currentQueue]
                needCheckCodeBlock:[self getLoginNeedCheckCodeBlock:callback on:currentQueue]];

}

+ (void)loginWithUserName:(NSString *)userName
              AndPassword:(NSString *)password
            loginResponse:(FMLoginResponseBlock)callback {
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
    [loginEngine loginWithUsername:userName
                          password:password
                               syn:NO
                          userInfo:nil
            needMainThreadCallBack:NO
                      successBlock:[self getLoginSuccessBlock:callback on:currentQueue]
                         failBlock:[self getLoginFailedBlock:callback on:currentQueue]
                needCheckCodeBlock:[self getLoginNeedCheckCodeBlock:callback on:currentQueue]];
}


+ (void)autoLogin:(FMLoginResponseBlock)callback {
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    FMUser *user = [FMApplication instance].loginUser;
    //没有用户名 一般是没有登陆过
    if (![user.name isNotBlank]) {
        FMLoginResponse *response = [[FMLoginResponse alloc] init];
        response.isSuccess = NO;
        response.errorString = @"没有用户名";
        if (callback)
            callback(response);
        return;
    }

    TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
    //应用重启后
    if (![user.sid isNotBlank] && [user.autoLoginToken isNotBlank]) {
        [loginEngine autoLoginWithUsername:user.name
                                 autoToken:user.autoLoginToken
                                       syn:NO
                                  userInfo:[NSDictionary dictionaryWithObject:@"1"
                                                                       forKey:NO_NEED_SAVE_SSO]
                    needMainThreadCallBack:NO
                              successBlock:[self getLoginSuccessBlock:callback on:currentQueue]
                                 failBlock:[self getLoginFailedBlock:callback on:currentQueue]];
        return;
    }

    //应用激活
    if ([user.sid isNotBlank]) {
        void (^autologinBlock)(TBSDKErrorResponse *, BOOL) = ^(TBSDKErrorResponse *errorResponse, BOOL adjective) {
            if (errorResponse || !adjective) {
                [loginEngine autoLoginWithUsername:user.name
                                         autoToken:user.autoLoginToken
                                               syn:NO
                                          userInfo:[NSDictionary dictionaryWithObject:@"1"
                                                                               forKey:NO_NEED_SAVE_SSO]
                            needMainThreadCallBack:NO
                                      successBlock:[self getLoginSuccessBlock:callback on:currentQueue]
                                         failBlock:[self getLoginFailedBlock:callback on:currentQueue]];
            } else {
                FMLoginResponse *response = [[FMLoginResponse alloc] init];
                response.isSuccess = YES;
                if (callback)
                    callback(response);
            }
        };
        [loginEngine checkSessionAdjectiveWithUsername:user.name
                                                   sid:user.sid
                                                   syn:NO
                                needMainThreadCallBack:NO
                                                 block:autologinBlock];
        return;
    }

    FMLoginResponse *response = [[FMLoginResponse alloc] init];
    response.isSuccess = NO;
    response.errorString = @"没有有效的sid或autoLoginToken进行自动登录";
    if (callback)
        callback(response);
    return;

}

+ (void)ssoLogin:(FMLoginResponseBlock)callback {
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    TBSDKSSOLoginEngine *ssoLoginEngine = [TBSDKSSOLoginEngine shareInstance];
    TBSDKSSOLoginAccountInfo *info = [ssoLoginEngine getSSOLoginAppInfo];
    if (info) {
        [ssoLoginEngine
                ssoLoginWithsuccessBlock:^(TBSDKSSOLoginEngine *_ssoLoginEngine, NSString *responseString) {
                    TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
                    [self getLoginSuccessBlock:callback on:currentQueue](loginEngine, responseString);
                }
                               failBlock:^(TBSDKSSOLoginEngine *_ssoLoginEngine, TBSDKErrorResponse *errorResponse,
                                       NSString *responseString) {
                                   TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
                                   [self getLoginFailedBlock:callback on:currentQueue](loginEngine, errorResponse,
                                           responseString
                                   );
                               }];
    }
}

+ (void)refreshCheckCode:(FMRefreshCheckCodeResponseBlock)callback {
    TBSDKLoginEngine *loginEngine = [TBSDKLoginEngine shareInstance];
    [loginEngine refreshCheckCodeSyn:NO
                            userInfo:nil
              needMainThreadCallBack:NO
                        successBlock:^(TBSDKLoginEngine *_loginEngine, NSString *responseString) {
                            if (callback) {
                                callback(YES, _loginEngine.checkCodeId, _loginEngine.checkCodeURL, nil);
                            }
                        }
                           failBlock:^(TBSDKLoginEngine *_loginEngine, TBSDKErrorResponse *errorResponse,
                                   NSString *responseString) {
                               if (callback) {
                                   callback(NO, nil, nil, _loginEngine.errorResponse.msg);
                               }
                           }];
}


+ (void)logout {
    [[TBSDKLoginEngine shareInstance] logout];
    [[TBSDKSSOLoginEngine shareInstance] logoutSSO];
    FMUser *user = [FMApplication instance].loginUser;
    user.isLogin = NO;
    user.sid = nil;
    user.autoLoginToken = nil;
    user.ecode = nil;
    user.topSession = nil;
    user.cookies = nil;
    [ClientApiHandler instance].sid = nil;
    [Mtop3Handler instance].sid = nil;
    [TopHandler instance].topSession = nil;

    [[FMApplication instance] asyncSaveToPreference];

    [FMPushService updateDevice];
    TBMBGlobalSendNotificationForSEL(@selector($$logoutDone:));
    dispatch_async(dispatch_get_main_queue(), ^{
        [UT updateUserAccount:@""];
    }
    );
}

+ (BOOL)isLogin {
    FMUser *user = [FMApplication instance].loginUser;
    if (!user || ![user isLogin]) {
        return NO;
    }
    return YES;
}

@end