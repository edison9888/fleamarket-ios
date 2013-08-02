//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-7 下午2:06.
//


#import <Foundation/Foundation.h>
#import "FMMessageSummary.h"

@class FMMessageInfo;


@interface FMRemoteMessage : NSObject
@property(nonatomic, assign) FMessageType type;
@property(nonatomic, copy) NSString *receiverId;
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *commentId;
@property(nonatomic, copy) NSString *reporterId;
@property(nonatomic, copy) NSString *reporterNick;
@property(nonatomic, strong) id content;
@property(nonatomic, copy) NSString *lastTime;

- (BOOL)isValid;

- (FMMessageInfo *)toFMMessageInfo;
@end