
//
//  TbSecretMgr.h
//  SecretSdk
//
//  Created by lbeing on 13-3-14.
//  Copyright (c) 2013年 taobao. All rights reserved.
//

#include  <Foundation/Foundation.h>

@interface TBSecretMgr : NSObject
+(TBSecretMgr*)sharedInstance;
-(NSString *)getAppKeyWithIos;
-(NSString *)getTopSignWithParam:(NSDictionary *)data;
-(NSString *)getSecretParam:(NSString *)timestamp;
-(NSString *)getMtopSignWithParm:(NSDictionary *)data Api:(NSString *)api Version:(NSString*)v Ecode:(NSString *)ecode Imei:(NSString *)imei Imsi:(NSString *)imsi TimeStamp :(NSString*)timestamp;
-(NSString*)getTopTokenWithUser:(NSString *)user TimeStamp :(NSString*)timestamp;

/**
 动态存储数据
 **/
-(void)setObject:(id<NSCoding>)anObject forKey:(NSString *)aKey;
/**
 获取数据
 */
-(id)objectForkey:(NSString *)aKey;
/**
 删除数据
 **/
-(void)removeObjectForKey:(NSString *)aKey;
-(BOOL)checkMethodSecurity:(NSString *)cla SELName: (NSString *)selName;
@end

