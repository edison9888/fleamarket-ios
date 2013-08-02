//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-25 下午1:50.
//


#import <Foundation/Foundation.h>
#import "FMMessageSummary.h"


@interface FMMessageSearchCondition : NSObject

@property(nonatomic, assign) NSUInteger pageNo;
@property(nonatomic, assign) NSUInteger pageSize;
@property(nonatomic, assign) FMessageType type;
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *reporterId;
@property(nonatomic, copy) NSString *commentId;
@property(nonatomic, copy) NSString *userId;

- (id)initWithType:(FMessageType)type;

+ (id)objectWithType:(FMessageType)type;

- (NSString *)toSQL:(BOOL)isPage isSelect:(BOOL)isSelect;

- (NSArray *)toArgs:(BOOL)isPage;
@end