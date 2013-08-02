//
// Created by yuanxiao on 12-10-10.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EventDefine.h"
#import "FMMessageSummary.h"
#import "FMBaseService.h"

@class FMMessageConfig;
@class FMMessageInfo;
@class FMMessageList;

#define ROWS_PER_PAGE  @"10"

@interface FMMessageService : FMBaseService

+ (void)getReceiveMessageList:(NSString *)pageNo
                          ret:(void (^)(BOOL isSuccess, FMMessageList *messageList))ret;

+ (void)getSendMessageList:(NSString *)pageNo
                       ret:(void (^)(BOOL isSuccess, FMMessageList *messageList))ret;

+ (void)getMessageByIds:(NSArray *)ids
                success:(void (^)(NSArray *comments))success
                 failed:(void (^)(NSString *error))failed;

+ (void)clearRemoteUnreadCommentCount:(void (^)(BOOL success))result;

+ (void)countRemoteUnreadComment:(void (^)(NSNumber *count))success failed:(void (^)(NSString *error))failed;

+ (void)countUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *))resultBlock;

+ (void)countUnreadByType:(FMessageType)type itemId:(NSString *)itemId
                   result:(void (^)(NSNumber *))resultBlock;

//获取总的消息汇总
+ (void)getAllMessageSummary:(void (^)(NSArray *result))resultBlock;

+ (void)getMessageSummaryByType:(FMessageType)type
                         result:(void (^)(NSArray *result))resultBlock;

+ (void)getMessageInfoByPageNO:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        result:(void (^)(NSArray *))resultBlock;

+ (void)countUnread:(void (^)(NSNumber *result))resultBlock;

//获取买家信息,卖家信息,系统信息,活动信息总数
+ (void)countSystemAll:(void (^)(NSNumber *result))resultBlock;

+ (void)insertMessageInfo:(FMMessageInfo *)messageInfo result:(void (^)(NSNumber *))resultBlock;

+ (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                        result:(void (^)(NSArray *))resultBlock;

+ (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                    reporterId:(NSString *)reporterId
                        result:(void (^)(NSArray *))resultBlock;

//获取我收到的留言
+ (void)getReceiveCommentWithResult:(void (^)(NSArray *))resultBlock;

+ (void)clearSystemUnread:(FMessageType)type
                   result:(void (^)(NSNumber *result))resultBlock;

+ (void)clearTradeUnread:(FMessageType)type
                  itemId:(NSString *)itemId
                  result:(void (^)(NSNumber *result))resultBlock;

+ (void)clearCommentUnread:(NSString *)itemId
                reporterId:(NSString *)reporterId
                    result:(void (^)(NSNumber *result))resultBlock;

+ (void)clearUnreadWithResult:(void (^)(NSNumber *result))resultBlock;

+ (void)clearUnreadWithId:(NSInteger)id
                   result:(void (^)(NSNumber *result))resultBlock;

+ (void)clearUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *result))resultBlock;

+ (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                     result:(void (^)(NSNumber *))resultBlock;

+ (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                 reporterId:(NSString *)reporterId
                     result:(void (^)(NSNumber *))resultBlock;

+ (void)deleteSystemAllMessage:(void (^)(NSNumber *))resultBlock;
@end