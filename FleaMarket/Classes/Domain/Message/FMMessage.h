//
// Created by yuanxiao on 12-10-10.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface FMMessageList : NSObject {
    NSMutableArray *items;
    NSInteger _totalCount;
    NSString *_serverTime;
    BOOL _nextPage;
}

@annotate(FMMessageList, TBIU_ANN_TYPE : @"FMItemCommentDO")
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic) BOOL nextPage;
@property(nonatomic) NSInteger totalCount;
@property(nonatomic, copy) NSString *serverTime;

+ (FMMessageList *)getMessageListWithMessageInfoList:(NSArray *)array;

@end
