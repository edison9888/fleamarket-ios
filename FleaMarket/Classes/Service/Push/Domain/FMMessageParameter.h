//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-7 上午11:22.
//


#import <Foundation/Foundation.h>
#import "FMMessageSummary.h"


@interface FMMessageParameter : NSObject

@property(nonatomic, assign) FMessageType type;
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *reporterId;

- (id)initWithType:(FMessageType)type itemId:(NSString *)itemId reporterId:(NSString *)reporterId;

+ (id)objectWithType:(FMessageType)type itemId:(NSString *)itemId reporterId:(NSString *)reporterId;

- (id)initWithType:(FMessageType)type;

+ (id)objectWithType:(FMessageType)type;

- (id)initWithType:(FMessageType)type itemId:(NSString *)itemId;

+ (id)objectWithType:(FMessageType)type itemId:(NSString *)itemId;


@end