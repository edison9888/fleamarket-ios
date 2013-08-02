//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午1:54.
//


#import <Foundation/Foundation.h>
#import "FMMessageSummary.h"
#import "FMBaseDO.h"

@class FMReportInfo;

typedef enum {
    SEND = 1,
    RECEIVE = 2
} FMCommentType;


@interface FMMessageInfo : FMBaseDO
@property(nonatomic, copy) NSString *userId; //当前用户id
@property(nonatomic, assign) FMessageType type;  //消息类型
@property(nonatomic, copy) NSString *itemId;   //宝贝id
@property(nonatomic, assign) BOOL unread; //未读数
@property(nonatomic, retain) FMReportInfo *reporterInfo;  //对方id
@property(nonatomic, copy) NSString *content;     //消息内容
@property(nonatomic, assign) FMCommentType commentType;  //留言类型
@property(nonatomic, copy) NSString *commentId;   //留言id
@property(nonatomic, retain) NSDate *lastTime; //最新的消息时间

@property(nonatomic) id contentId; //由content转，json->对象

+ (FMMessageInfo *)objectFromFMResultSet:(FMResultSet *)resultSet;

- (NSArray *)toArgs;
@end