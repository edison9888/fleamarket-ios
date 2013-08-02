//
// Created by henson on 11/12/12.
// 

#import "FMMessageItemDAO.h"
#import "FMMessageItemInfo.h"
#import "NSString+Helper.h"

@implementation FMMessageItemDAO

- (id)init {
    self = [super init];
    if (self) {
        _messageItemCache = [[NSCache alloc] init];
    }

    return self;
}

+ (FMMessageItemDAO *)instance {
    static FMMessageItemDAO *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (FMMessageItemInfo *)getMessageItemInfo:(NSString *)itemId {
    if ([itemId isBlank]) {
        return nil;
    }
    return [_messageItemCache objectForKey:itemId];
}

- (void)saveMessageItemInfo:(FMMessageItemInfo *)messageItemInfo {
    if (!messageItemInfo) {
        return;
    }
    if ([messageItemInfo.itemId isBlank]) {
        return;
    }
    [_messageItemCache setObject:messageItemInfo forKey:messageItemInfo.itemId];
}

- (void)clearAllMessageItems {
    [_messageItemCache removeAllObjects];
}

@end