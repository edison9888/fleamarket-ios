//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-7 上午11:22.
//


#import "FMMessageParameter.h"


@implementation FMMessageParameter {

@private
    FMessageType _type;
    NSString *_itemId;
    NSString *_reporterId;
}
@synthesize type = _type;
@synthesize itemId = _itemId;
@synthesize reporterId = _reporterId;

- (id)initWithType:(FMessageType)type itemId:(NSString *)itemId reporterId:(NSString *)reporterId {
    self = [super init];
    if (self) {
        _type = type;
        _itemId = itemId;
        _reporterId = reporterId;
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

- (id)initWithType:(FMessageType)type itemId:(NSString *)itemId {
    self = [super init];
    if (self) {
        _type = type;
        _itemId = itemId;
    }

    return self;
}

+ (id)objectWithType:(FMessageType)type itemId:(NSString *)itemId {
    return [[FMMessageParameter alloc] initWithType:type itemId:itemId];
}


+ (id)objectWithType:(FMessageType)type {
    return [[FMMessageParameter alloc] initWithType:type];
}


+ (id)objectWithType:(FMessageType)type itemId:(NSString *)itemId reporterId:(NSString *)reporterId {
    return [[FMMessageParameter alloc] initWithType:type itemId:itemId reporterId:reporterId];
}


@end