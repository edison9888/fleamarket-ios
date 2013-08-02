//
//  TBSDKPushCenterNewEngine.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-7.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSDKPushCenterDataSubscribeGetDataModel.h"

@class TBSDKPushCenterContext;

typedef enum {
    TBSDKPushCenterNewsSubscribeTypeStatusOne = 1,                              //全天关闭
    TBSDKPushCenterNewsSubscribeTypeStatusTwo = 2,                              //全天接收
    TBSDKPushCenterNewsSubscribeTypeStatusThree = 3                             //固定有效期接收
}TBSDKPushCenterNewsSubscribeTypeStatus;

/** PushCenter消息订阅服务类 <br/> 
 *  主要提供功能：
 *          1、获取消息订阅配置
 *          2、更新消息订阅配置
 *          3、获取消息摘要
 *          4、获取消息详情
 */
@interface TBSDKPushCenterNewEngine : NSObject

/** 以单例模式初始化 */
+ (id)shareInstance;

/** 获取设备或用户订阅配置，主要封装 mtop.push.subscribe.get
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.subscribe.fetchSubscribeCfg_v4
 *
 *  如果sessionID和sToken同时为nil，获取的是"设备订阅信息"。如果这两个值有一个不为nil，获取的是"用户订阅信息"。
 *
 *  @param  sessionID                   淘系用户传入sid，非淘系用户传入nil
 *  @param  sToken                      淘系用户传入nil，非淘系用户传入用户登陆标示
 *  @param  type                        接收设置
 *  @param  userInfo                    回调的时候，model携带的userInfo。用于回调传参和辨别是哪个请求的回调
 *  @param  pushCenterContext           保存了回调的设置，回调的方式有两种，一种代理回调，block回调
 *
 */
- (void)getNewsSubscribeNewsListWithSessionID:(NSString *)sessionID
                                       sToken:(NSString *)sToken
                                         type:(TBSDKPushCenterNewsSubscribeType)type
                                     userInfo:(NSDictionary *)userInfo
                                      context:(TBSDKPushCenterContext *)pushCenterContext;

/** 更新设备或用户订阅配置，主要封装了mtop.push.subscribe.update
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.subscribe.updateSubscribeCfg_v4
 *
 *  如果sessionID和sToken同时为nil，更新的是"设备订阅信息"。如果这两个值有一个不为nil，更新的是"用户订阅信息"。
 *
 *  @param  sessionID                   淘系用户传入sid，非淘系用户传入nil
 *  @param  sToken                      淘系用户传入nil，非淘系用户传入用户登陆标示
 *  @param  stauts                      接收消息的控制状态
 *  @param  msgTypes                    需要更新的消息
 *  @param  userInfo                    回调的时候，model携带的userInfo。用于回调传参和辨别是哪个请求的回调
 *  @param  pushCenterContext           保存了回调的设置，回调的方式有两种，一种代理回调，block回调
 *
 */
- (void)updateNewsSubscribeWithSessionID:(NSString *)sessionID
                                  sToken:(NSString *)sToken
                                  status:(TBSDKPushCenterNewsSubscribeTypeStatus)stauts
                                msgTypes:(NSArray *)msgTypes
                                userInfo:(NSDictionary *)userInfo
                                 context:(TBSDKPushCenterContext *)pushCenterContext;

/** 获取订阅的摘要，主要封装了mtop.push.msg.new
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.msg.new_v4
 *
 *  @param  startIndex                  查询的第一条消息的id,如果是第一页，则可以为空
 *  @param  type                        消息类型，由业务方决定，如果为空，则取所有消息类型的消息，如果有最大长度为50
 *  @param  number                      需要返回的消息数量，最大为30，不过返回结果会多一个，做为下一页的起始index，如果为空，默认为1
 *  @param  userInfo                    回调的时候，model携带的userInfo。用于回调传参和辨别是哪个请求的回调
 *  @param  pushCenterContext           保存了回调的设置，回调的方式有两种，一种代理回调，block回调
 *
 */
- (void)getSubscribeSummaryWithStartIndex:(NSString *)startIndex
                                     type:(NSString *)type
                                   number:(int)number
                                 userInfo:(NSDictionary *)userInfo
                                  context:(TBSDKPushCenterContext *)pushCenterContext;

/** 获取订阅的详情，主要封装了mtop.push.msg.get
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.msg.get_v4
 *
 *  @param  messageID                   消息id的集合
 *  @param  userInfo                    回调的时候，model携带的userInfo。用于回调传参和辨别是哪个请求的回调
 *  @param  pushCenterContext           保存了回调的设置，回调的方式有两种，一种代理回调，block回调
 *
 */
- (void)getSubscribeDetailWithMessageID:(NSArray *)messageID
                               userInfo:(NSDictionary *)userInfo
                                context:(TBSDKPushCenterContext *)pushCenterContext;

@end