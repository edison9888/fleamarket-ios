//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-1 下午12:28.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"


#define FM_UPDATE_DEVICE_DONE     @"FM_UPDATE_DEVICE_DONE"
#define FM_UPDATE_DEVICE_FAILED   @"FM_UPDATE_DEVICE_FAILED"

@interface FMPushService : FMBaseService
////废弃
//+ (void)createDeviceId;
//
////废弃
//+ (void)registerDevice;

//绑定用户和deviceId的关系
+ (void)updateDevice;

//注册deviceToken
+ (void)registerDeviceToken:(NSData *)deviceToken;


+ (void)getNewPush:(NSUInteger)num ret:(void (^)(NSUInteger retCount, NSArray *msg_ids))ret;

+ (void)getContentPush:(NSArray *)messageIds  ret:(void (^)(NSArray *contents))ret;

+ (void)fetchSubscribeCfg:(void (^)(BOOL isSuccess, NSArray *subscribes))ret;

+ (void)updateSubscribeCfg:(BOOL)on ret:(void (^)(BOOL isSuccess))ret;

@end