//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午1:35.
//


#import <Foundation/Foundation.h>
#import "FMBaseDO.h"

@class FMResultSet;

typedef enum {
    COMMENT = 1, //留言
    BUY, //买家信息
    SOLD, //卖家信息
    SYSTEM, //系统信息
    ACTIVITY,  //活动信息
    END,  //结束标志位
    SYSTEMALL,  //买家信息,卖家信息,系统信息,活动信息
    QUEUE = 255 //发布队列
} FMessageType;

//汇总消息
@interface FMMessageSummary : FMBaseDO
@property(nonatomic, copy) NSString *userId; //当前用户id
@property(nonatomic, assign) FMessageType type;  //消息类型
@property(nonatomic, assign) NSUInteger unread; //未读数
@property(nonatomic, copy) NSString *desc; //备注
@property(nonatomic, retain) NSDate *lastTime; //最新的消息时间
@property(nonatomic, retain) id userInfo; //用户自定义信息,比如留言的对象是谁/以及nick
@property(nonatomic, copy) NSString *itemId;//对应的商品id

+ (FMMessageSummary *)objectFromFMResultSet:(FMResultSet *)resultSet;

+ (FMMessageSummary *)objectWithType:(FMessageType)type AndUserId:(NSString *)userId;

- (void)overWrite:(FMMessageSummary *)messageSummary;

@end