//
//  TBSDKPushCenterDataSubscribeSummaryDataModel.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-9.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import "TBSDKPushCenterModel.h"

/** 获取消息摘要的数据处理类
 *  通过访问网络获取消息摘要，然后解析为对象
 *  http://dev.wireless.taobao.net/mediawiki/index.php?title=Mtop.push.msg.new_v4
 */
@interface TBSDKPushCenterSubscribeSummaryDataModel : TBSDKPushCenterModel

/** 保存TBSDKPushCenterMessageListObject对象集合 */
@property (nonatomic, strong) NSMutableArray                                    *messageList;

/** 接口返回的appkey */
@property (nonatomic, strong) NSString                                          *appkey;

/** */
@property (nonatomic, strong) NSString                                          *pollingInterval;

/** */
@property (nonatomic, strong) NSString                                          *startIndex;

/** */
@property (nonatomic, strong) NSString                                          *type;

/** */
@property (nonatomic, unsafe_unretained) int                                    number;

@end
