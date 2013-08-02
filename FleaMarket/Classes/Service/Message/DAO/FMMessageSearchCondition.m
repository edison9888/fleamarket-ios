//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-25 下午1:50.
//


#import "FMMessageSearchCondition.h"


@implementation FMMessageSearchCondition {

@private
    NSUInteger _pageNo;
    NSUInteger _pageSize;
    FMessageType _type;
    NSString *_itemId;
    NSString *_reporterId;
    NSString *_userId;
    NSString *_commentId;
}
@synthesize pageNo = _pageNo;
@synthesize pageSize = _pageSize;
@synthesize type = _type;
@synthesize itemId = _itemId;
@synthesize reporterId = _reporterId;
@synthesize userId = _userId;


@synthesize commentId = _commentId;

- (id)init {
    self = [super init];
    if (self) {
        _pageNo = 1;
        _pageSize = 20;
    }
    return self;
}

- (id)initWithType:(FMessageType)type {
    self = [super init];
    if (self) {
        _type = type;
    }

    return self;
}

+ (id)objectWithType:(FMessageType)type {
    return [[FMMessageSearchCondition alloc] initWithType:type];
}


- (NSString *)toSQL:(BOOL)isPage isSelect:(BOOL)isSelect {
    NSMutableString *prefix = [[NSMutableString alloc] initWithString:@" user_id=? "];
    if (_type > 0) {
        if (_type == SYSTEMALL) {
            [prefix appendString:@"AND (type=? "];
            [prefix appendString:@"OR type=? "];
            [prefix appendString:@"OR type=? "];
            [prefix appendString:@"OR type=? )"];
        } else {
            [prefix appendString:@"AND type=? "];
        }
    }
    if (_itemId) {
        [prefix appendString:@"AND item_id=? "];
    }
    if (_reporterId) {
        [prefix appendString:@"AND reporter_id=? "];
    }
    if (_commentId) {
        [prefix appendString:@"AND comment_id=? "];
    }
    if (isSelect) {
        [prefix appendString:@"ORDER BY last_time DESC "];
    }
    if (isPage) {
        [prefix appendString:@"LIMIT ? OFFSET ?"];
    }
    return prefix;
}

- (NSArray *)toArgs:(BOOL)isPage {
    NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity:6];
    [args addObject:_userId];
    if (_type > 0) {
        if (_type == SYSTEMALL) {
            [args addObject:[NSNumber numberWithInt:BUY]];
            [args addObject:[NSNumber numberWithInt:SOLD]];
            [args addObject:[NSNumber numberWithInt:SYSTEM]];
            [args addObject:[NSNumber numberWithInt:ACTIVITY]];
        } else {
            [args addObject:[NSNumber numberWithInt:_type]];
        }
    }
    if (_itemId) {
        [args addObject:_itemId];
    }
    if (_reporterId) {
        [args addObject:_reporterId];
    }
    if (_commentId) {
        [args addObject:_commentId];
    }
    if (isPage) {
        [args addObject:[NSNumber numberWithInt:_pageSize]];
        [args addObject:[NSNumber numberWithInt:(_pageNo - 1) * _pageSize]];
    }
    return args;
}


@end