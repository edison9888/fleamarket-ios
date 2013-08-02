// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <TaobaoRemoteObject/RemoteContext.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import <TaobaoRemoteObject/HandlerDefine.h>
#import <TaobaoRemoteObject/ClientApiHandler.h>
#import "FMItemCommentService.h"
#import "NSString+Helper.h"
#import "FMCommentDO.h"
#import "FMItemCommentDO.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMCommon.h"
#import "FMCommentReplyDO.h"
#import "FMMessageInfo.h"
#import "FMMessageDAO.h"
#import "FMReportInfo.h"

#define kErShouItemCommentsAPI @"comment.list"
#define kPerPageCount @"20"
#define kErShouItemCommentPublish @"publish.comment"
#define kErShouItemCommentReply @"reply.comment"
#define kErShouItemCommentDelete @"delete.comment"

@implementation FMItemCommentService {

}

+ (void)getComments:(NSString *)itemId
               page:(NSString *)page
             result:(void (^)(BOOL, FMItemCommentDOList *, NSString *))result {
    if (!itemId || [itemId isBlank]) {
        if (result) {
            result(NO, nil, @"ItemId is empty.");
        }
        return;
    }

    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouItemCommentsAPI
                                                version:kApiErShouVersion];
    NSDictionary *params = @{@"itemId" : itemId ? : @"", @"pageNumber" : page, @"rowsPerPage" : kPerPageCount};
    info.returnClass = [FMItemCommentDOList class];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
        } else {
            if (result) {
                result(NO, nil, @"获取留言失败");
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

+ (void)publishComment:(FMCommentDO *)commentDO
                result:(void (^)(BOOL, FMItemCommentDO *, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouItemCommentPublish
                                                version:kApiErShouVersion];
    context.info = info;
    context.parameter = commentDO;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            FMMessageInfo *messageInfo = [[FMMessageInfo alloc] init];
            messageInfo.unread = NO;
            messageInfo.commentId = [NSString stringWithFormat:@"%lld", [clientApiBaseReturn.data longLongValue]];
            messageInfo.content = commentDO.content;
            messageInfo.itemId = commentDO.itemId;
            messageInfo.type = COMMENT;
            messageInfo.commentType = SEND;
            messageInfo.reporterInfo.reporterId = [NSString stringWithFormat:@"%lld", commentDO.sellerId];
            messageInfo.reporterInfo.reporterNick = commentDO.sellerName;
            messageInfo.reporterInfo.reporterName = commentDO.sellerName;
            [[FMMessageDAO instance] insertMessageInfo:messageInfo result:NULL];

            if (result) {
                FMUser *user = [FMApplication instance].loginUser;
                FMItemCommentDO *itemCommentDO = [[FMItemCommentDO alloc] init];
                itemCommentDO.commentId = [clientApiBaseReturn.data longLongValue];
                itemCommentDO.itemId = [commentDO.itemId longLongValue];
                itemCommentDO.reporterId = [user.id longLongValue];
                itemCommentDO.sellerId = commentDO.sellerId;
                itemCommentDO.content = commentDO.content;
                itemCommentDO.reportTime = [FMCommon nowDateTimeString];
                itemCommentDO.reporterName = user.name;
                itemCommentDO.reporterNick = user.name;
                itemCommentDO.sellerNick = commentDO.sellerName;
                itemCommentDO.voiceUrl = commentDO.voiceUrl;
                result(YES, itemCommentDO, nil);
            }
        } else {
            if (result) {
                result(NO, nil, clientApiBaseReturn.desc);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");

        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];

}

+ (void)replyComment:(FMCommentReplyDO *)commentReplyDO
        result:(void (^)(BOOL, FMItemCommentDO *, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouItemCommentReply
                                                version:kApiErShouVersion];
    context.info = info;
    context.parameter = commentReplyDO;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                FMUser *user = [FMApplication instance].loginUser;
                FMItemCommentDO *itemCommentDO = [[FMItemCommentDO alloc] init];
                itemCommentDO.commentId = [clientApiBaseReturn.data longLongValue];
                itemCommentDO.itemId = [commentReplyDO.itemId longLongValue];
                itemCommentDO.reporterId = [user.id longLongValue];
                itemCommentDO.sellerId = commentReplyDO.sellerId;
                itemCommentDO.content = [NSString stringWithFormat:@"回复@%@(%@,%lld):%@",commentReplyDO.beReplierNick, commentReplyDO.beReplierNick, commentReplyDO.beReplierId, commentReplyDO.content];
                itemCommentDO.reportTime = [FMCommon nowDateTimeString];
                itemCommentDO.reporterName = user.name;
                itemCommentDO.reporterNick = user.name;
                itemCommentDO.sellerNick = commentReplyDO.sellerName;
                itemCommentDO.voiceUrl = commentReplyDO.voiceUrl;
                result(YES, itemCommentDO, nil);
            }

            FMMessageInfo *messageInfo = [[FMMessageInfo alloc] init];
            messageInfo.unread = NO;
            messageInfo.commentId = [NSString stringWithFormat:@"%lld", commentReplyDO.commentId];
            messageInfo.content = commentReplyDO.content;
            messageInfo.itemId = commentReplyDO.itemId;
            messageInfo.type = COMMENT;
            messageInfo.commentType = SEND;
            if (commentReplyDO.sellerId != commentReplyDO.beReplierId) {
                messageInfo.reporterInfo.reporterId = [NSString stringWithFormat:@"%lld", commentReplyDO.sellerId];
                messageInfo.reporterInfo.reporterNick = commentReplyDO.sellerName;
                messageInfo.reporterInfo.reporterName = commentReplyDO.sellerName;
            } else {
                messageInfo.reporterInfo.reporterId = [NSString stringWithFormat:@"%lld", commentReplyDO.beReplierId];
                messageInfo.reporterInfo.reporterNick = commentReplyDO.beReplierNick;
                messageInfo.reporterInfo.reporterName = commentReplyDO.beReplierNick;
            }
            [[FMMessageDAO instance] insertMessageInfo:messageInfo result:NULL];
            return;
        }

        if (result) {
            result(NO, nil, clientApiBaseReturn.desc);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

+ (void)deleteComment:(NSString *)commentId
               itemId:(NSString *)itemId
               result:(void (^)(BOOL isSuccess, NSString *errMsg))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouItemCommentDelete
                                                version:kApiErShouVersion];
    NSDictionary *params = @{@"itemId" : itemId ? : @"", @"commentId" : commentId};
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, nil);
            }
            return;
        }
        if (result) {
            result(NO, @"删除留言失败");
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"api_%@:%@", kApiErShouVersion, event.context.errorMessage);
        if (result) {
            result(NO, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

@end