//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午2:14.
//


#import <Foundation/Foundation.h>
#import "FMMessageSummary.h"

@class FMMessageInfo;

@interface FMMessageDAO : NSObject

+ (FMMessageDAO *)instance;

//初始化Message相关的DB
- (void)initMessageDB;

//获取总的消息汇总
- (void)getAllMessageSummary:(void (^)(NSArray *result))resultBlock;

//用于获取买家 和 买家信息
- (void)getMessageSummaryByType:(FMessageType)type result:(void (^)(NSArray *result))resultBlock;

//用于获取活动 和 系统
- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        result:(void (^)(NSArray *result))resultBlock;

//用于获取买卖信息
- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                        result:(void (^)(NSArray *result))resultBlock;


//用于获取留言
- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                    reporterId:(NSString *)reporterId
                        result:(void (^)(NSArray *result))resultBlock;

//获取我收到的留言总数
- (void)getReceiveCommentWithResult:(void (^)(NSArray *))resultBlock;


//用于清除未读活动 和 系统
- (void)clearUnreadByType:(FMessageType)type
                   result:(void (^)(NSNumber *result))resultBlock;

//用于清除未读买卖信息
- (void)clearUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
                   result:(void (^)(NSNumber *result))resultBlock;

//用于清除未读留言
- (void)clearUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *result))resultBlock;

//用于清除买家信息,卖家信息,系统信息,活动信息
- (void)clearUnreadWithResult:(void (^)(NSNumber *result))resultBlock;

- (void)clearUnreadWithId:(NSInteger)_id
                   result:(void (^)(NSNumber *result))resultBlock;

//用于读取未读买卖信息
- (void)countUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
                   result:(void (^)(NSNumber *result))resultBlock;

//用于读取未读留言
- (void)countUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *result))resultBlock;

//用于删除活动 和 系统
- (void)deleteMessageByType:(FMessageType)type
                     result:(void (^)(NSNumber *result))resultBlock;

//用于删除买卖信息
- (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                     result:(void (^)(NSNumber *result))resultBlock;

//用于删除留言
- (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                 reporterId:(NSString *)reporterId
                     result:(void (^)(NSNumber *result))resultBlock;

//用于删除留言
- (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                  commentId:(NSString *)commentId
                     result:(void (^)(NSNumber *result))resultBlock;

- (void)deleteSystemAllMessage:(void (^)(NSNumber *result))resultBlock;

//插入新消息
- (void)insertMessageInfo:(FMMessageInfo *)messageInfo
                   result:(void (^)(NSNumber *result))resultBlock;

- (void)insertMessageInfoNoMax:(FMMessageInfo *)messageInfo result:(void (^)(NSNumber *))resultBlock;

- (void)countUnread:(void (^)(NSNumber *result))resultBlock;

- (void)countSystemAll:(void (^)(NSNumber *result))resultBlock;

- (void)deleteAllByUser:(void (^)(NSNumber *result))resultBlock;

- (void)deleteAll:(void (^)(NSNumber *result))resultBlock;

@end