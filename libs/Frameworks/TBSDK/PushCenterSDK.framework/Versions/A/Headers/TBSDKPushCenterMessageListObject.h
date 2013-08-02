//
//  TBSDKPushCenterMessageListObject.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-9.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

/** "mtop.push.msg.get"返回值的数据模型对象
 * http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.msg.get_v4
 */
@interface TBSDKPushCenterMessageListObject : NSObject

/** 消息id */
@property (nonatomic, strong) NSString                                          *messageID;

/** 任务id */
@property (nonatomic, strong) NSString                                          *task;

/** 消息类型 */
@property (nonatomic, strong) NSString                                          *type;

/** 消息摘要 */
@property (nonatomic, strong) NSString                                          *digest;

/** 消息详情 */
@property (nonatomic, strong) NSString                                          *content;

/** 初始化方法
 *
 *  @param  dict   服务器返回值
 */
- (id)initWithDict:(NSDictionary *)dict;

@end