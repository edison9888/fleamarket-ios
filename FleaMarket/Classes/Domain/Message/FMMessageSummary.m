//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午1:35.
//


#import "FMMessageSummary.h"
#import "FMResultSet.h"
#import "FMReportInfo.h"
#import "FMCommon.h"


@implementation FMMessageSummary {
@private
    NSString *_itemId;
    NSString *_userId;
    FMessageType _type;
    NSUInteger _unread;
    NSString *_desc;
    NSDate *_lastTime;
    id _userInfo;
}
@synthesize itemId = _itemId;
@synthesize userId = _userId;
@synthesize type = _type;
@synthesize unread = _unread;
@synthesize desc = _desc;
@synthesize lastTime = _lastTime;
@synthesize userInfo = _userInfo;

+ (FMMessageSummary *)objectFromFMResultSet:(FMResultSet *)resultSet {
    FMMessageSummary *summary = [[FMMessageSummary alloc] init];
    summary.id = [resultSet intForColumn:@"id"];
    summary.itemId = [resultSet stringForColumn:@"item_id"];
    summary.userId = [resultSet stringForColumn:@"user_id"];
    summary.type = (FMessageType) [resultSet intForColumn:@"type"];
    summary.unread = (NSUInteger) [resultSet intForColumn:@"sum(unread)"];
    summary.desc = [resultSet stringForColumn:@"content"];
    if (summary.type == COMMENT) {
        FMReportInfo *info = [[FMReportInfo alloc] init];
        info.reporterId = [resultSet stringForColumn:@"reporter_id"];
        info.reporterNick = [resultSet stringForColumn:@"reporter_nick"];
        info.reporterName = [resultSet stringForColumn:@"reporter_name"];
        summary.userInfo = info;
    }
    NSString *time = [resultSet stringForColumn:@"last_time"];
    summary.lastTime = time ? [[FMCommon postTimeDateFormatter] dateFromString:time] : nil;
    return summary;
}

+ (FMMessageSummary *)objectWithType:(FMessageType)type AndUserId:(NSString *)userId {
    FMMessageSummary *summary = [[FMMessageSummary alloc] init];
    summary.type = type;
    summary.userId = userId;
    summary.unread = 0;
    return summary;
}

- (void)overWrite:(FMMessageSummary *)messageSummary {
    _unread += messageSummary.unread;
    if ([messageSummary.lastTime compare:_lastTime] > 0) {
        _desc = messageSummary.desc;
        _lastTime = messageSummary.lastTime;
        _userInfo = messageSummary.userInfo;
    }
}


@end