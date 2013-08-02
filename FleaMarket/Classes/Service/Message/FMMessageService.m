//
// Created by yuanxiao on 12-10-10.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMMessageService.h"
#import "ClientApiInfo.h"
#import "RemoteContext.h"
#import "ClientApiHandler.h"
#import "FMMessage.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"
#import "FMMessageDAO.h"

#define kApiMyReceiveComment                     @"my.receive.comment"
#define kApiMyPublishComment                     @"my.publish.comment"


@implementation FMMessageService

+ (void)getReceiveMessageList:(NSString *)pageNo
                          ret:(void (^)(BOOL, FMMessageList *))ret {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kApiMyReceiveComment
                                                version:kApiErShouVersion];
    info.returnClass = [FMMessageList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageNo,
                                                                      @"pageNumber",
                                                                      ROWS_PER_PAGE,
                                                                      @"rowsPerPage",
                                                                      nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (ret) {
                FMMessageList *data = clientApiBaseReturn.data;
                ret(YES, data);
            }
        } else {
            if (ret) {
                ret(NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (ret) {
            ret(NO, nil);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

+ (void)getSendMessageList:(NSString *)pageNo
                       ret:(void (^)(BOOL, FMMessageList *))ret {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kApiMyPublishComment
                                                version:kApiErShouVersion];
    info.returnClass = [FMMessageList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageNo,
                                                                      @"pageNumber",
                                                                      ROWS_PER_PAGE,
                                                                      @"rowsPerPage",
                                                                      nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (ret) {
                FMMessageList *data = clientApiBaseReturn.data;
                ret(YES, data);
            }
        } else {
            if (ret) {
                ret(NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (ret) {
            ret(NO, nil);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}


+ (void)getMessageByIds:(NSArray *)ids success:(void (^)(NSArray *))success failed:(void (^)(NSString *))failed {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"get.comments.by.ids"
                                                version:kApiErShouVersion];
    info.returnClass = [FMMessageList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ids,
                                                                      @"commentIds",
                                                                      nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (success) {
                FMMessageList *data = clientApiBaseReturn.data;
                success(data.items);
            }
        } else {
            if (failed) {
                failed(clientApiBaseReturn.desc);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (failed) {
            failed(nil);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}


+ (void)clearRemoteUnreadCommentCount:(void (^)(BOOL))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"clear.my.unread.comment"
                                                version:kApiErShouVersion];
    context.info = info;
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES);
            }
        } else {
            if (result) {
                result(NO);
            }
        }

    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}


+ (void)countRemoteUnreadComment:(void (^)(NSNumber *))success failed:(void (^)(NSString *))failed {
    RemoteContext *context = [[RemoteContext alloc] init];
    [context.userInfo setObject:@"1" forKey:@"isDaemon"];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"my.unread.comment.count"
                                                version:kApiErShouVersion];
    context.info = info;
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (success) {
                success([clientApiBaseReturn.data objectForKey:@"count"]);
            }
        } else {
            if (failed) {
                failed(clientApiBaseReturn.desc);
            }
        }

    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (failed) {
            failed(nil);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

+ (void)getAllMessageSummary:(void (^)(NSArray *result))resultBlock {
    [[FMMessageDAO instance] getAllMessageSummary:resultBlock];
}

+ (void)getMessageSummaryByType:(FMessageType)type result:(void (^)(NSArray *result))resultBlock {
    [[FMMessageDAO instance] getMessageSummaryByType:type result:resultBlock];
}

+ (void)countUnreadByType:(FMessageType)type itemId:(NSString *)itemId
                   result:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] countUnreadByType:type itemId:itemId result:resultBlock];
}

+ (void)countUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] countUnreadByType:type itemId:itemId reporterId:reporterId
                                        result:resultBlock];
}

+ (void)getMessageInfoByPageNO:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        result:(void (^)(NSArray *))resultBlock {
    [[FMMessageDAO instance] getMessageInfoByPageNo:pageNo
                                        AndPageSize:pageSize
                                               type:type
                                             result:resultBlock];
}

+ (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                        result:(void (^)(NSArray *))resultBlock {
    [[FMMessageDAO instance] getMessageInfoByPageNo:pageNo
                                        AndPageSize:pageSize
                                               type:type
                                             itemId:itemId
                                             result:resultBlock];

}

+ (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                    reporterId:(NSString *)reporterId
                        result:(void (^)(NSArray *))resultBlock {

    [[FMMessageDAO instance] getMessageInfoByPageNo:pageNo
                                        AndPageSize:pageSize
                                               type:type
                                             itemId:itemId
                                         reporterId:reporterId
                                             result:resultBlock];
}

+ (void)getReceiveCommentWithResult:(void (^)(NSArray *))resultBlock {

}

+ (void)countUnread:(void (^)(NSNumber *result))resultBlock {
    [[FMMessageDAO instance] countUnread:resultBlock];
}

+ (void)countSystemAll:(void (^)(NSNumber *result))resultBlock {
    [[FMMessageDAO instance] countSystemAll:resultBlock];
}

+ (void)insertMessageInfo:(FMMessageInfo *)messageInfo result:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] insertMessageInfo:messageInfo result:resultBlock];
}


//用于清除未读活动 和 系统
+ (void)clearSystemUnread:(FMessageType)type
                   result:(void (^)(NSNumber *result))resultBlock {
    if (type != ACTIVITY && type != SYSTEM) {
        return;
    }
    [FMMessageService clearUnreadByType:type
                                 itemId:nil reporterId:nil result:^(NSNumber *result) {
        if (resultBlock) {
            resultBlock(result);
        }
    }];

}

//用于清除未读买卖信息
+ (void)clearTradeUnread:(FMessageType)type
                  itemId:(NSString *)itemId
                  result:(void (^)(NSNumber *result))resultBlock {
    if (type != SOLD && type != BUY) {
        return;
    }

    if ([itemId intValue] < 1) {
        return;
    }
    [FMMessageService clearUnreadByType:type
                                 itemId:itemId
                             reporterId:nil result:^(NSNumber *result) {
        if (resultBlock) {
            resultBlock(result);
        }
    }];

}

//用于清除未读留言信息
+ (void)clearCommentUnread:(NSString *)itemId
                reporterId:(NSString *)reporterId
                    result:(void (^)(NSNumber *result))resultBlock {
    if ([itemId intValue] < 1 || [reporterId intValue] < 1) {
        return;
    }

    [FMMessageService clearUnreadByType:COMMENT
                                 itemId:itemId
                             reporterId:reporterId
                                 result:^(NSNumber *result) {
                                     if (resultBlock) {
                                         resultBlock(result);
                                     }
                                 }];


}

+ (void)clearUnreadWithResult:(void (^)(NSNumber *result))resultBlock {
    [[FMMessageDAO instance] clearUnreadWithResult:resultBlock];
}

+ (void)clearUnreadWithId:(NSInteger)id
                   result:(void (^)(NSNumber *result))resultBlock {
    [[FMMessageDAO instance] clearUnreadWithId:id result:resultBlock];
}

//用于清除未读消息
+ (void)clearUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *result))resultBlock {
    if ((itemId && [itemId length] > 0) && (reporterId && [reporterId length] > 0)) {
        [[FMMessageDAO instance] clearUnreadByType:type
                                            itemId:itemId
                                        reporterId:reporterId
                                            result:^(NSNumber *result) {
                                                if (resultBlock) {
                                                    resultBlock(result);
                                                }
                                            }];
        return;
    }

    if (itemId && [itemId length] > 0) {
        [[FMMessageDAO instance] clearUnreadByType:type
                                            itemId:itemId
                                            result:^(NSNumber *result) {
                                                if (resultBlock) {
                                                    resultBlock(result);
                                                }
                                            }];
        return;
    }

    [[FMMessageDAO instance] clearUnreadByType:type result:^(NSNumber *result) {
        if (resultBlock) {
            resultBlock(result);
        }
    }];
}

//删除
+ (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                     result:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] deleteMessageByType:type itemId:itemId
                                          result:^(NSNumber *result) {
                                              if (resultBlock) {
                                                  resultBlock(result);
                                              }
                                          }];
}

+ (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                 reporterId:(NSString *)reporterId
                     result:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] deleteMessageByType:type
                                          itemId:itemId
                                      reporterId:reporterId
                                          result:^(NSNumber *result) {
                                              if (resultBlock) {
                                                  resultBlock(result);
                                              }
                                          }];
}

+ (void)deleteSystemAllMessage:(void (^)(NSNumber *))resultBlock {
    [[FMMessageDAO instance] deleteSystemAllMessage:resultBlock];
}

@end