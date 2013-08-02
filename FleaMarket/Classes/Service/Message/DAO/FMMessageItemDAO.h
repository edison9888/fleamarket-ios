//
// Created by henson on 11/12/12.
// 

#import <Foundation/Foundation.h>

@class FMMessageItemInfo;

@interface FMMessageItemDAO : NSObject {

@private
    NSCache *_messageItemCache;
}

+ (FMMessageItemDAO *)instance;

- (FMMessageItemInfo *)getMessageItemInfo:(NSString *)itemId;

- (void)saveMessageItemInfo:(FMMessageItemInfo *)messageItemInfo;

- (void)clearAllMessageItems;

@end