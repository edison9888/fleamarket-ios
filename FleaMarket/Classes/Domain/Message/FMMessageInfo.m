//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午1:54.
//


#import "FMMessageInfo.h"
#import "FMReportInfo.h"
#import "FMResultSet.h"
#import "FMCommon.h"
#import "FMTradeMessageInfo.h"
#import "NSString+TBIU_JSONToObject.h"
#import "FMSystemMessageContent.h"


@implementation FMMessageInfo {
@private
    NSString *_userId;
    FMessageType _type;
    NSString *_itemId;
    FMReportInfo *_reporterInfo;
    NSString *_content;
    NSDate *_lastTime;
    BOOL _unread;
    FMCommentType _commentType;
    NSString *_commentId;
}
@synthesize userId = _userId;
@synthesize type = _type;
@synthesize itemId = _itemId;
@synthesize reporterInfo = _reporterInfo;
@synthesize content = _content;
@synthesize lastTime = _lastTime;
@synthesize unread = _unread;
@synthesize commentType = _commentType;
@synthesize commentId = _commentId;

- (id)init {
    self = [super init];
    if (self) {
        _lastTime = [NSDate date];
        _reporterInfo = [[FMReportInfo alloc] init];
        _commentType = RECEIVE;
    }
    return self;
}


+ (FMMessageInfo *)objectFromFMResultSet:(FMResultSet *)resultSet {
    FMMessageInfo *messageInfo = [[FMMessageInfo alloc] init];
    messageInfo.id = [resultSet intForColumn:@"id"];
    messageInfo.itemId = [resultSet stringForColumn:@"item_id"];
    messageInfo.userId = [resultSet stringForColumn:@"user_id"];
    messageInfo.type = (FMessageType) [resultSet intForColumn:@"type"];
    messageInfo.unread = [resultSet boolForColumn:@"unread"];
    messageInfo.commentType = (FMCommentType) [resultSet intForColumn:@"comment_type"];
    messageInfo.commentId = [resultSet stringForColumn:@"comment_id"];
    messageInfo.content = [resultSet stringForColumn:@"content"];
    FMReportInfo *info = [[FMReportInfo alloc] init];
    info.reporterId = [resultSet stringForColumn:@"reporter_id"];
    info.reporterNick = [resultSet stringForColumn:@"reporter_nick"];
    info.reporterName = [resultSet stringForColumn:@"reporter_name"];
    messageInfo.reporterInfo = info;
    NSString *time = [resultSet stringForColumn:@"last_time"];
    messageInfo.lastTime = time ? [[FMCommon postTimeDateFormatter] dateFromString:time] : nil;
    return messageInfo;
}

#define D_NULL(A) ((A)?:[NSNull null])

- (NSArray *)toArgs {
    NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity:9];
    [args addObject:D_NULL(self.userId)];
    [args addObject:D_NULL([NSNumber numberWithInt:_type])];
    [args addObject:D_NULL([NSNumber numberWithBool:_unread])];
    [args addObject:D_NULL(self.itemId)];
    [args addObject:D_NULL(self.reporterInfo.reporterId)];
    [args addObject:D_NULL(self.reporterInfo.reporterNick)];
    [args addObject:D_NULL(self.reporterInfo.reporterName)];
    [args addObject:D_NULL([NSNumber numberWithInt:_commentType])];
    [args addObject:D_NULL(self.commentId)];
    [args addObject:D_NULL(self.content)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [args addObject:D_NULL([formatter stringFromDate:self.lastTime])];
    return args;
}

- (id)contentId {
    if (!_commentId) {
        if (self.type == SOLD || self.type == BUY) {
            _commentId = [self.content jsonToObjectWithClass:[FMTradeMessageInfo class]];
        } else if (self.type == ACTIVITY || self.type == SYSTEM) {
            _commentId = [self.content jsonToObjectWithClass:[FMSystemMessageContent class]];
        }
    }
    return _commentId;
}

@end