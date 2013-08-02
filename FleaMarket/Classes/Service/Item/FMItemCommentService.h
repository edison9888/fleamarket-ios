// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMItemCommentDOList;
@class FMCommentDO;
@class FMItemCommentDO;
@class FMCommentReplyDO;

@interface FMItemCommentService : FMBaseService

+ (void)getComments:(NSString *)itemId
               page:(NSString *)page
             result:(void (^)(BOOL, FMItemCommentDOList *, NSString *))result;

+ (void)publishComment:(FMCommentDO *)commentDO
                result:(void (^)(BOOL, FMItemCommentDO *, NSString *))result;

+ (void)replyComment:(FMCommentReplyDO *)commentReplyDO
              result:(void (^)(BOOL, FMItemCommentDO *, NSString *))result;

+ (void)deleteComment:(NSString *)commentId
               itemId:(NSString *)itemId
               result:(void (^)(BOOL isSuccess, NSString *errMsg))result;

@end