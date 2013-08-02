//
//  TBSDKServer.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-1-28.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBSDK_REQUEST_NOT_NETWORK   @"tbsdk request not network"    //无网络
#define TBSDK_REQUEST_TIME_OUT      @"tbsdk request timeout"        //请求超时

@protocol TBSDKErrorHandleDelegate;
@protocol TBSDKServerDelegate;
@protocol TBSDKErrorRule;

@class TBSDKRequest;
@class TBSDKRequestDataSource;
@class TBSDKErrorResponse;
@class TBSDKServer;
@class TBSDKServerQueue;


typedef void (^StartBlock)(TBSDKServer      *server);
typedef void (^FinishedBlock)(TBSDKServer   *server);
typedef void (^FailBlock)(TBSDKServer       *server);

/** TBSDKMTOPServer和TBSDKTOPServer的父类
 *
 * 定义了一些抽象方法和虚函数（本身没有任何实现，需要子类重载），这些方法和属性不和具体的业务联系
 * 定义虚函数的原因：因为TBSDKMTOPServer和TBSDKTOPServer都有类似的方法（实现不同），
 * 同时都需要放到请求池中，所以就需要定义虚函数。
 *
 */
@interface TBSDKServer : NSObject

@property (nonatomic, assign) id <TBSDKServerDelegate>                          delegate;

#pragma mark - 错误处理

/** TBSDK业务错误处理类
 *
 *  默认情况下errorHandle为nil，缺省的会根据TOP/MTOP“标准”返回数据格式，来处理业务错误。
 *
 *  用户设置errorHandle后，当TOP/MTOP服务器返回数据后，TBSDKServer会调用errorHandle处理返回数据的业务错误。
 *
 *  判断本次网络返回的数据是否成功很困难，因为TOP/MTOP一些接口返回的数据不标准（有的返回 "::SUCCESS" 表示成功，有的返回 "::成功" 表示成功），
 *  所以很多时候需要TBSDKServer的调用者自己判断调用是否成功。
 *
 *  errorHandle要实现 “- (id<TBSDKErrorRule>)tbsdkErrorHandleWitServer:(TBSDKServer *)server”代理方法。返回值会保存在“tbsdkError”中。
 *  如果返回nil表示服务器成功返回业务数据，TBSDKServer将要调用delegate的 “- (void)requestFinished:(TBSDKServer *)server”方法
 *  如果返回TBSDKError对象，TBSDKServer将要调用delegate的 “- (void)requestFailed:(TBSDKServer *)server”方法。
 *
 */
@property (nonatomic, assign) id<TBSDKErrorHandleDelegate>                      errorHandle;

/** 本次请求的错误描述对象.
 *
 *  如果没有错误此对象为nil，反之将不为nil。
 *  如果tbsdkError.errorCode = TBSDK_REQUEST_NOT_NETWORK，表示无网络。
 *  如果tbsdkError.errorCode = TBSDK_REQUEST_TIME_OUT，表示请求超时。
 *
 */
@property (nonatomic, strong) id<TBSDKErrorRule>                                tbsdkError;

#pragma mark - 回调方法

/** 请求开始时的 selector，默认为 - (void)requestStarted:(TBSDKServer *)server; */
@property (nonatomic, assign) SEL                                               requestDidStartSelector;

/** 请求成功时的 selector，默认为 - (void)requestSuccess:(TBSDKServer *)server; */
@property (nonatomic, assign) SEL                                               requestDidFinishSelector;

/** 请求失败时的 selector，默认为 - (void)requestFailed:(TBSDKServer *)server; */
@property (nonatomic, assign) SEL                                               requestDidFailedSelector;

#pragma mark - 回调块

@property (nonatomic, copy) StartBlock                                          onStartBlock;
@property (nonatomic, copy) FinishedBlock                                       onFinishedBlock;
@property (nonatomic, copy) FailBlock                                           onFailBlock;

#pragma mark -

//! 发送请求对象。
@property (nonatomic, strong, readonly) TBSDKRequest                            *tbsdkRequest;

//! url组装器
@property (nonatomic, strong, readonly) TBSDKRequestDataSource                  *tbsdkRequestDataSource;

//! 请求的参数
@property (nonatomic, strong) NSMutableDictionary                               *params;

/** 服务返回JSON格式的对象。
*
*   将服务器返回的字符串解析为对象。
*   请调用者获取此数据后保存，以免多次访问此属性造成系统压力。
*
*/
@property (nonatomic, strong, readonly) id                                      responseJSON;

//! NSData 对象的请求响应数据
@property (nonatomic, retain, readonly) NSData                                  *responseData;

//! NSString 对象的请求响应数据
@property (nonatomic, retain, readonly) NSString                                *responseString;

//! 设置编码，默认为UTF8
@property (nonatomic, assign) NSStringEncoding                                  responseEncoding;

/** 请求的目标的主URL。
 *
 *  一般情况下不需要设置此属性，会自动使用TOP或MTOP的主URL。
 *  用户可以设置自己的URL地址。
 */
@property (nonatomic, strong) NSString                                          *mainURLForRequest;

//! API名称
@property (nonatomic, strong, readonly) NSString                                *apiMethod;

//! YES,表示使用POSTt方法，反之使用GET方法。默认NO。
@property (nonatomic, unsafe_unretained) BOOL                                   usePost;

//! 网络请求的超时时间(秒)，默认30秒钟
@property (nonatomic, unsafe_unretained) NSTimeInterval                         timeOutSeconds;

//! 调用者设置，当网络返回的时候，会有这样参数(异步调用的时候)
@property (nonatomic, strong) NSDictionary                                      *userInfo;

//! 对本次网络请求的标示（一般异步请求设置）
@property (nonatomic, unsafe_unretained) NSInteger                              tag;

/** 当登录失效时，自动登录，并重新请求当前api，
 *
 * 注意: 只有app中同时集成了LoginSDK的情况下此参数才会生效，而且只针对TOP和MTOP接口自动登录
 *
 *  YES，自动登录，NO，不自动登录。默认为NO。
 *
 */
@property (nonatomic, unsafe_unretained) BOOL                                   autoLogin;

#pragma mark - 方法

//! 开始同步网络请求, 当网络请求完成或失败后返回
- (void)startSynchronous;

//! 开始异步请求
- (void)startAsynchronous;

//! 清理delegate和blocks, 然后终止本次网络请求
- (void)clearDelegatesAndCancel;

- (void)clearData;


@end
