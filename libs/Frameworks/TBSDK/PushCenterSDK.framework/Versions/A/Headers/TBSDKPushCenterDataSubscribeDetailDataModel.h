//
//  TBSDKPushCenterDataSubscribeDetailDataModel.h
//  TBSDkPushCenterSDK
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-9.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#import "TBSDKPushCenterModel.h"

/** 获取消息的数据处理类
 */
@interface TBSDKPushCenterDataSubscribeDetailDataModel : TBSDKPushCenterModel

/** 需要获取消息详情的messageID */
@property (nonatomic, strong) NSArray                                           *messageIDs;    

/** 服务器返回值。
 *  保存TBSDKPushCenterMessageListObject对象集合，没有对象保存了对该消息的详细描述。
 */
@property (nonatomic, strong) NSMutableArray                                    *messageList;   

@end
