//
//  TopServer.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-1-28.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSDKServer.h"

/** TOP的网络请求类。
 *
 * TBSDK的使用者直接使用此类，来从TOP服务器获取数据。
 */
@interface TBSDKTOPServer : TBSDKServer

@property (nonatomic, unsafe_unretained) BOOL                                   needsUserSession;

/*! 创建一个指定方法的请求
 *
 *  @param  method  方法名称，例如 com.taobao.items.search
 *  autoRelease对象，如果要保持存在，请自己retain。
 */
+ (id)requestWithMethod:(NSString *)method;

/*! 创建一个指定方法的请求
 *
 *  @param method 方法名称，例如 com.taobao.items.search
 */
- (id)initWithMethod:(NSString *)method;

/*! 添加请求参数
 *
 *  @param param    参数值
 *  @param key      参数名称
 */
- (void)addParam:(NSObject*)param forKey:(NSString*)key;

//! 删除请求参数
- (void)removeParam:(NSString *)key;

@end