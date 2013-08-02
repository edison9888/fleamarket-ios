//
//  PushCenterSubscribeConfigObject.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-7.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

/** "mtop.push.subscribe.get"返回值的数据模型对象 
 * http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.subscribe.fetchSubscribeCfg_v4
 */
@interface PushCenterSubscribeConfigObject : NSObject

/** 接收消息的控制状态：1全天关闭；2全天接收；3固定有效期接收 */
@property (nonatomic, strong) NSString                                          *status;

/** msgTypesArray内存储的“SubscribeConfigObject”对象 */
@property (nonatomic, strong) NSMutableArray                                    *msgTypesArray;

/** 初始化方法
 *  @param  dict   服务器返回值
 */
- (id)initWithDict:(NSDictionary *)dict;

@end