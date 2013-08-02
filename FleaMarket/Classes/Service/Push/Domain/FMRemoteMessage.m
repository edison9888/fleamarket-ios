//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-7 下午2:06.
//


#import "FMRemoteMessage.h"
#import "FMMessageInfo.h"
#import "FMReportInfo.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "NSObject+TBIU_ToJson.h"
#import "NSString+Helper.h"


@implementation FMRemoteMessage {

@private
    FMessageType _type;
    NSString *_itemId;
    NSString *_commentId;
    NSString *_reporterId;
    NSString *_reporterNick;
    NSString *_content;
    NSString *_lastTime;
    NSString *_receiverId;
}
@synthesize type = _type;
@synthesize itemId = _itemId;
@synthesize commentId = _commentId;
@synthesize reporterId = _reporterId;
@synthesize reporterNick = _reporterNick;
@synthesize content = _content;
@synthesize lastTime = _lastTime;
@synthesize receiverId = _receiverId;


- (BOOL)isValid {
    BOOL ret = YES;
    if (_type < COMMENT || _type >= END) {
        ret = NO;
    }
    if (_type == COMMENT || _type == BUY || _type == SOLD) {
        if (![_receiverId isEqualToString:[FMApplication instance].loginUser.id]) {
            ret = NO;
        }
    }

    if (_content == nil) {
        ret = NO;
    }
    return ret;
}

- (FMMessageInfo *)toFMMessageInfo {
    FMMessageInfo *messageInfo = [[FMMessageInfo alloc] init];
    messageInfo.unread = YES;
    messageInfo.commentId = _commentId;
    if (_type == COMMENT && [_content isKindOfClass:[NSString class]]) {
        messageInfo.content = _content;
    } else {
        messageInfo.content = [_content toJSONString];
    }
    messageInfo.itemId = _itemId;
    messageInfo.type = _type;
    messageInfo.commentType = RECEIVE;
    messageInfo.reporterInfo.reporterId = _reporterId;
    messageInfo.reporterInfo.reporterNick = _reporterNick;
    messageInfo.reporterInfo.reporterName = _reporterNick;
    if ([_lastTime isNotBlank]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[NSLocale currentLocale]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [df dateFromString:_lastTime];
        if (date)
            messageInfo.lastTime = date;
    }
    return messageInfo;
}

@end