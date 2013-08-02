//
//  MTopServer.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-1-28.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSDKServer.h"

#define MTOP_REQUEST_DATA_KEY @"data"

@class TBSDKRequestDataSource;
@class TBSDKRequest;

/** MTOP的网络请求类。
 *
 * TBSDK的使用者直接使用此类，来从MTOP服务器获取数据。
 */
@interface TBSDKMTOPServer : TBSDKServer

//! MTOP请求的业务参数
@property (nonatomic, strong, readonly) NSMutableDictionary                     *dataDict;

/* 需要设定独立的sid和eCode */
@property (nonatomic, unsafe_unretained) BOOL                                   needEcodeSign;
@property (nonatomic, strong) NSString                                          *sid;
@property (nonatomic, strong) NSString                                          *eCode;


/*! 创建一个指定方法的请求
 *
 *  @param  method  方法名称，例如 com.taobao.items.search
 */
+ (id)requestWithMethod:(NSString *)method;

/*! 创建一个指定方法的请求
 *
 *  @param method 方法名称，例如 com.taobao.items.search
 */
- (id)initWithMethod:(NSString *)method;

/** 添加“协议”参数
 *
 *  @param param    参数值
 *  @param key      参数名称
 */
- (void)addParam:(NSObject*)param forKey:(NSString*)key;

//! 删除“协议”请求参数
- (void)removeParam:(NSString *)key;

/*! 添加无线 MTOP 请求"业务"参数
 *
 *  @param param    参数值
 *  @param key      参数名称
 */
- (void)addDataParam:(NSObject*)param forKey:(NSString*)key;

/** 删除MTOP 请求"业务"参数
 *
 *  @param  key     使用“addDataParam:forKey:传入的key”
 *  @see    - addDataParam:forKey:
 */
- (void)removeDataParam:(NSString *)key;

@end
