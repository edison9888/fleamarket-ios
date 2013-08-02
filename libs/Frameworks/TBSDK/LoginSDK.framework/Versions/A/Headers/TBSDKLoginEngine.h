//
//  TBSDKLoginEngine.h
//  TBSDKLoginSDK
//
//  Created by 亿刀 on 13-3-27.
//  Copyright (c) 2013年 亿刀. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSDKLoginEngine;
@class TBSDKErrorResponse;
@class TBSDKLoginConfiguration;
@class TBSDKConfiguration;

typedef void (^TBSDKLoginSuccessBlock)(TBSDKLoginEngine *loginEngine, NSString *responseString);
typedef void (^TBSDKLoginFailBlock)(TBSDKLoginEngine *loginEngine, TBSDKErrorResponse *errorResponse, NSString *responseString);
typedef void (^TBSDKLoginNeedCheckCodeBlock)(TBSDKLoginEngine *loginEngine, NSString *checkCodeId, NSString *checkCodeURL);

@interface TBSDKLoginEngine : NSObject

/** 是否https登录
 *
 *  YES，https登录。NO，http登录。默认是YES。
 **/
@property (nonatomic, unsafe_unretained) BOOL                                   httpsLogin;

@property (nonatomic, strong, readonly) NSString                                *ssoToken;

/** 错误描述对象 */
@property (nonatomic, strong, readonly) TBSDKErrorResponse                      *errorResponse;

/** 验证码Id */
@property (nonatomic, strong, readonly) NSString                                *checkCodeId;

/** 验证码URL */
@property (nonatomic, strong, readonly) NSString                                *checkCodeURL;

@property (nonatomic, strong, readonly) NSDictionary                            *userInfo;

/** TBSDKNetworkSDK配置对象 */
@property (nonatomic, strong) TBSDKConfiguration                                *loginConfiguration;

+ (TBSDKLoginEngine *)shareInstance;

/** 用户名和密码密码登录
 *
 *  @param  userName                用户名nick
 *  @param  pwd                     密码
 *  @param  synchronous             是否为同步请求
 *  @param  successBlock            异步登录成功回调block
 *  @param  failBlock               异步登录失败回调block
 *  @param  needCheckCodeBlock      异步登录，需要输入验证码登录回调block
 *  @param  needMainThreadCallBack  是否需要在主线程回调block。YES，在主线程回调block。NO，在当前线程回调
 *
 *  @note   如果synchronous=NO；表示为同步请求successBlock、successBlock、needCheckCodeBlock请传入nil。
 */
- (void)loginWithUsername:(NSString *)userName
                 password:(NSString *)pwd
                      syn:(BOOL)synchronous
                 userInfo:(NSDictionary *)userInfo
   needMainThreadCallBack:(BOOL)needMainThreadCallBack
             successBlock:(TBSDKLoginSuccessBlock)successBlock
                failBlock:(TBSDKLoginFailBlock)failBlock
       needCheckCodeBlock:(TBSDKLoginNeedCheckCodeBlock)needCheckCodeBlock;

/** 带验证码登录
 *
 *  @param  userName                用户名nick
 *  @param  pwd                     密码
 *  @param  checkCodeId             验证码ID
 *  @param  checkCode               用户输入的验证码
 *  @param  synchronous             是否为同步请求
 *  @param  needMainThreadCallBack  是否需要在主线程回调block。YES，在主线程回调block。NO，在当前线程回调
 *  @param  successBlock            异步登录成功回调block
 *  @param  failBlock               异步登录失败回调block
 *  @param  needCheckCodeBlock      异步需要输入验证码登录回调block
 *
 *  @note   如果synchronous=NO；表示为同步请求successBlock和successBlock请传入nil。
 */
- (void)loginWithUsername:(NSString *)userName
                 password:(NSString *)pwd
              checkCodeId:(NSString *)checkCodeId
                checkCode:(NSString*)checkCode
                      syn:(BOOL)synchronous
                 userInfo:(NSDictionary *)userInfo
   needMainThreadCallBack:(BOOL)needMainThreadCallBack
             successBlock:(TBSDKLoginSuccessBlock)successBlock
                failBlock:(TBSDKLoginFailBlock)failBlock
       needCheckCodeBlock:(TBSDKLoginNeedCheckCodeBlock)needCheckCodeBlock;

/** 带验证码登录
 *
 *  @param  userName                            用户名nick
 *  @param  autoLoginToken                      自动登录token
 *  @param  synchronous                         是否为同步请求
 *  @param  needMainThreadCallBack              是否需要在主线程回调block。YES，在主线程回调block。NO，在当前线程回调
 *  @param  successBlock                        异步登录成功回调block
 *  @param  failBlock                           异步登录失败回调block
 *
 *  @note   如果synchronous=NO；表示为同步请求successBlock和successBlock请传入nil。
 */
- (void)autoLoginWithUsername:(NSString *)userName
                    autoToken:(NSString *)autoLoginToken
                          syn:(BOOL)synchronous
                     userInfo:(NSDictionary *)userInfo
       needMainThreadCallBack:(BOOL)needMainThreadCallBack
                 successBlock:(TBSDKLoginSuccessBlock)successBlock
                    failBlock:(TBSDKLoginFailBlock)failBlock;

/** 检查登录状态是否有效
 *
 *  @param  username                用户名nick
 *  @param  sid                     mtop登录标示
 *  @param  synchronous             是否为同步请求
 *  @param  needMainThreadCallBack  是否需要在主线程回调block。YES，在主线程回调block。NO，在当前线程回调
 *  @param  block                   如果synchronous设置NO，请求完成后就会回调block,负责请在TBSDKLoginEngine的属性中获取errorResponse
 */
- (BOOL)checkSessionAdjectiveWithUsername:(NSString *)username
                                      sid:(NSString *)sid
                                      syn:(BOOL)synchronous
                   needMainThreadCallBack:(BOOL)needMainThreadCallBack
                                    block:(void (^)(TBSDKErrorResponse *errorResponse, BOOL adjective))block;

/** 刷新验证码
 *
 *  @param  synchronous                         是否为同步请求
 *  @param  needMainThreadCallBack              是否需要在主线程回调block。YES，在主线程回调block。NO，在当前线程回调
 *  @param  successBlock                        异步登录成功回调block
 *  @param  failBlock                           异步登录失败回调block
 *
 *  @note   如果synchronous=NO；表示为同步请求successBlock和successBlock请传入nil
 */
- (void)refreshCheckCodeSyn:(BOOL)synchronous
                   userInfo:(NSDictionary *)userInfo
     needMainThreadCallBack:(BOOL)needMainThreadCallBack
               successBlock:(TBSDKLoginSuccessBlock)successBlock
                  failBlock:(TBSDKLoginFailBlock)failBlock;

/** 退出请求 */
- (void)cancelReqeust;

/** 等出 */
- (void)logout;

@end
