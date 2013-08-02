//
//  TBSDKPushCenterUserTrackEngine.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-18.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPageForPushCenter @"agoo"
#define kEventIDForPushCenter 20005

/** TBSDKPushCenterUserTrackEngine用于推送消息统计，如推送消息到达率等。
 */
@interface TBSDKPushCenterUserTrackEngine : NSObject

/** 激活打点，SDK内部调用 */
+ (void)activating;

/** 收到push消息后，埋点。 
 *
 *  @param  userInfo    launchOptions或userInfo
 */
+ (void)userTrackForReceivePushWithAPS:(NSDictionary *)userInfo;

/** 用户读取的了一个消息的详情 
 *
 *  @param  task    服务器返回的任务id，可以在TBSDKPushCenterMessageListObject对象中获取
 */
+ (void)userTrackForReadWithMessageList:(NSArray *)messageList;

@end