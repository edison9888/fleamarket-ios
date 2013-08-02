//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-1 下午12:28.
//


#import "TBSDKNetworkSDK.h"
#import "TBSDKPushCenterEngine.h"
#import "TBSDKPushCenterConfiguration.h"
#import "TBSDKPushCenterNewEngine.h"
#import "TBSDKPushCenterContext.h"
#import "TBSDKPushCenterSubscribeSummaryDataModel.h"
#import "TBSDKPushCenterDataSubscribeDetailDataModel.h"
#import "TBSDKPushCenterDataSubscribeUpdateDataModel.h"
#import "PushCenterSubscribeConfigObject.h"
#import "SubscribeConfigObject.h"
#import "TBSDKPushCenterMessageListObject.h"
#import "TBSDKPushCenterUserTrackEngine.h"
#import "FMPushService.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "NSString+Helper.h"
#import "FMRemoteMessage.h"
#import "NSString+TBIU_JSONToObject.h"


@implementation FMPushService {

}
+ (void)updateDevice {

    TBSDKPushCenterEngine *pushCenterEngine = [TBSDKPushCenterEngine shareInstance];
    if ([FMApplication instance].loginUser.isLogin) {
        [pushCenterEngine
                bindUserIntoPushCenterWithSessionID:[FMApplication instance].loginUser.sid
                                             sToken:nil
                                           userInfo:nil
                                   bindSuccessBlock:^(TBSDKPushCenterModel *model) {
                                       FMLOG(@"成功:绑定");
                                       [[NSNotificationCenter defaultCenter]
                                                              postNotificationName:FM_UPDATE_DEVICE_DONE
                                                                            object:nil];
                                   }
                                      bindFailBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *error) {
                                          FMLOG(@"失败:绑定, error = %@", [error description]);
                                          [[NSNotificationCenter defaultCenter]
                                                                 postNotificationName:FM_UPDATE_DEVICE_FAILED
                                                                               object:nil];
                                      }];
    } else {

        TBSDKPushCenterConfiguration *configuration = [TBSDKPushCenterConfiguration shareInstance];
        [pushCenterEngine
                unbindUserIntoPushCenterWithPushUserToken:configuration.pushUserToken
                                                 userInfo:nil
                                       unBindSuccessBlock:^(TBSDKPushCenterModel *model) {
                                           FMLOG(@"成功:解除绑定");
                                           [[NSNotificationCenter defaultCenter]
                                                                  postNotificationName:FM_UPDATE_DEVICE_DONE
                                                                                object:nil];

                                       }
                                          unBindFailBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *error) {
                                              FMLOG(@"失败:解除绑定, error = %@", [error description]);
                                              [[NSNotificationCenter defaultCenter]
                                                                     postNotificationName:FM_UPDATE_DEVICE_FAILED
                                                                                   object:nil];
                                          }];
    }
}


+ (void)registerDeviceToken:(NSData *)deviceToken {
    if (deviceToken.length) {
        TBSDKPushCenterEngine *pushCenterEngine = [TBSDKPushCenterEngine shareInstance];
        [pushCenterEngine upLoaderDeviceToken:deviceToken
                                     userInfo:nil
                           uploadSuccessBlock:^(TBSDKPushCenterModel *model) {
                               FMLOG(@"成功:上传deviceToken");
                           }
                              uploadFailBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *error) {
                                  FMLOG(@"失败:上传deviceToken, error = %@", [error description]);
                              }];
    }
}

+ (void)getNewPush:(NSUInteger)num ret:(void (^)(NSUInteger retCount, NSArray *msg_ids))ret {
    //调用mtop.push.msg.new接口获取消息摘要
    TBSDKPushCenterContext *centerContext =
            [TBSDKPushCenterContext
                    contextWithModelDelegate:nil
                           modelSuccessBlock:^(TBSDKPushCenterModel *model) {
                               TBSDKPushCenterSubscribeSummaryDataModel *subscribeSummaryDataModel = (TBSDKPushCenterSubscribeSummaryDataModel *) model;
                               NSArray *messageList = subscribeSummaryDataModel.messageList;
                               if (messageList && [messageList count] > 0) {
                                   NSMutableArray *messageIds = [[NSMutableArray alloc]
                                                                                 initWithCapacity:messageList.count];
                                   for (TBSDKPushCenterMessageListObject *message in messageList) {
                                       [messageIds addObject:message.messageID];
                                   }
                                   if (ret) {
                                       ret([messageList count], messageIds);
                                   }
                               }
                           }
                           modelFailureBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *response) {
                               FMLOG(@"%@", [model.error debugDescription]);
                           }];
    [[TBSDKPushCenterNewEngine shareInstance]
                               getSubscribeSummaryWithStartIndex:nil
                                                            type:nil
                                                          number:num
                                                        userInfo:[NSDictionary dictionaryWithObject:centerContext
                                                                                             forKey:@"Fuck"]
                                                         context:centerContext];
}

+ (void)getContentPush:(NSArray *)messageIds ret:(void (^)(NSArray *))ret {
    if (!messageIds.count) {
        return;
    }

    TBSDKPushCenterContext *centerContext =
            [TBSDKPushCenterContext
                    contextWithModelDelegate:nil
                           modelSuccessBlock:^(TBSDKPushCenterModel *model) {
                               TBSDKPushCenterDataSubscribeDetailDataModel *subscribeDetailDataModel = (TBSDKPushCenterDataSubscribeDetailDataModel *) model;
                               NSArray *messageList = subscribeDetailDataModel.messageList;
                               if (messageList && [messageList count] > 0) {
                                   NSMutableArray *messageObjects = [[NSMutableArray alloc]
                                                                                     initWithCapacity:messageList.count];
                                   for (TBSDKPushCenterMessageListObject *message in messageList) {
                                       [TBSDKPushCenterUserTrackEngine userTrackForReadWithMessageList:messageList];
                                      NSString *content = message.content;
                                      if ([content isNotBlank]) {
                                           FMRemoteMessage *remoteMessage = [content jsonToObjectWithClass:[FMRemoteMessage class]];
                                           if (remoteMessage.isValid) {
                                               [messageObjects addObject:remoteMessage];
                                           }
                                       }
                                   }
                                   if (ret) {
                                       ret(messageObjects);
                                   }
                               }
                           }
                           modelFailureBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *response) {
                               FMLOG(@"%@", [model.error debugDescription]);
                           }];
    //调用mtop.push.msg.get，获取push信息详情
    [[TBSDKPushCenterNewEngine shareInstance] getSubscribeDetailWithMessageID:messageIds
                                                                     userInfo:[NSDictionary dictionaryWithObject:centerContext
                                                                                                          forKey:@"Fuck"]
                                                                      context:centerContext];
}


+ (void)fetchSubscribeCfg:(void (^)(BOOL, NSArray *))ret {
    TBSDKPushCenterContext *centerContext =
            [TBSDKPushCenterContext
                    contextWithModelDelegate:nil
                           modelSuccessBlock:^(TBSDKPushCenterModel *model) {
                               FMLOG(@"%@", model);
                               TBSDKPushCenterDataSubscribeGetDataModel *dataModel = (TBSDKPushCenterDataSubscribeGetDataModel *) model;
                               if (ret) {
                                   NSArray *types = dataModel.pushCenterSubscribeConfigObject.msgTypesArray;
                                   NSMutableArray *subscribes = [[NSMutableArray alloc] initWithCapacity:[types count]];
                                   for (SubscribeConfigObject *type in types) {
                                       if (type.subscribe)
                                           [subscribes addObject:type.regType];
                                   }
                                   ret(YES, subscribes);
                               }

                           }
                           modelFailureBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *response) {
                               FMLOG(@"%@", [model.error debugDescription]);
                               if (ret) {
                                   ret(NO, nil);
                               }
                           }];
    //获取“用户”或“设备”的消息订阅配置
    [[TBSDKPushCenterNewEngine shareInstance] getNewsSubscribeNewsListWithSessionID:[FMApplication instance]
            .loginUser.sid
                                                                             sToken:nil
                                                                               type:TBSDKPushCenterNewsSubscribeTypeAll
                                                                           userInfo:[NSDictionary dictionaryWithObject:centerContext
                                                                                                                forKey:@"Fuck"]
                                                                            context:centerContext];
}


+ (void)updateSubscribeCfg:(BOOL)on ret:(void (^)(BOOL))ret {
    NSArray *subscribeType = @[@"fleamarket_comment", @"fleamarket_buy_message", @"fleamarket_sold_message",
            @"fleamarket_system_message", @"fleamarket_activity_message"];
    NSMutableArray *subscribeConfigObjectArray = [NSMutableArray arrayWithCapacity:5];
    for (NSUInteger i = 0; i < 5; i++) {
        SubscribeConfigObject *subscribeConfigObject = [[SubscribeConfigObject alloc] init];
        subscribeConfigObject.regType = [subscribeType objectAtIndex:i];
        subscribeConfigObject.subscribe = on;
        [subscribeConfigObjectArray addObject:subscribeConfigObject];
    }
    TBSDKPushCenterContext *centerContext =
            [TBSDKPushCenterContext
                    contextWithModelDelegate:nil
                           modelSuccessBlock:^(TBSDKPushCenterModel *model) {
                               TBSDKPushCenterDataSubscribeUpdateDataModel *dataModel = (TBSDKPushCenterDataSubscribeUpdateDataModel *) model;
                               FMLOG(@"%@", model);
                               if (ret) {
                                   NSMutableArray *array = dataModel.pushCenterSubscribeConfigObject.msgTypesArray;
                                   if (array.count > 0) {
                                       SubscribeConfigObject *o = [array objectAtIndex:0];
                                       ret([@"SUCCESS" isEqualToString:o.resultCode]);
                                   } else {
                                       ret(NO);
                                   }
                               }
                           }
                           modelFailureBlock:^(TBSDKPushCenterModel *model, TBSDKErrorResponse *response) {
                               FMLOG(@"%@", [model.error debugDescription]);
                               if (ret) {
                                   ret(NO);
                               }
                           }];

    [[TBSDKPushCenterNewEngine shareInstance] updateNewsSubscribeWithSessionID:[FMApplication instance].loginUser.sid
                                                                        sToken:nil
                                                                        status:TBSDKPushCenterNewsSubscribeTypeStatusTwo
                                                                      msgTypes:subscribeConfigObjectArray
                                                                      userInfo:[NSDictionary dictionaryWithObject:centerContext
                                                                                                           forKey:@"Fuck"]
                                                                       context:centerContext];
}


@end