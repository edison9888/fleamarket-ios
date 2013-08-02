//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 下午2:47.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"


@interface FMLoginResponse : NSObject
@property(nonatomic, assign) BOOL isSuccess;
@property(nonatomic, assign) BOOL needCheckCode;
@property(nonatomic, copy) NSString *responseString;
@property(nonatomic, copy) NSString *errorString;
@property(nonatomic, copy) NSString *checkCodeId;
@property(nonatomic, copy) NSString *checkCodeUrl;
@end

typedef void(^FMLoginResponseBlock)(FMLoginResponse *loginResponse);

typedef void(^FMRefreshCheckCodeResponseBlock)(BOOL isSuccess, NSString *checkCodeId, NSString *checkCodeUrl,
        NSString *error);

@interface FMLoginService : FMBaseService

+ (void)loginWithUserName:(NSString *)userName
              AndPassword:(NSString *)password
           AndCheckCodeId:(NSString *)checkCodeId
             AndCheckCode:(NSString *)checkCode
            loginResponse:(FMLoginResponseBlock)callback;

+ (void)loginWithUserName:(NSString *)userName
              AndPassword:(NSString *)password
            loginResponse:(FMLoginResponseBlock)callback;

+ (void)autoLogin:(FMLoginResponseBlock)callback;

+ (void)ssoLogin:(FMLoginResponseBlock)callback;

+ (void)refreshCheckCode:(FMRefreshCheckCodeResponseBlock)callback;

+ (void)logout;

+ (BOOL)isLogin;
@end