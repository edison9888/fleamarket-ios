//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-2-20 上午9:11.
//


#import <Foundation/Foundation.h>


@interface TBROSync : NSObject

+ (TBROSync *)instance;

- (void)startWithHost:(NSString *)host api:(NSString *)api version:(NSString *)version needSyncFirst:(BOOL)needSyncFirst;

- (void)reSync;

- (NSString *)getPublicIp;

- (NSDate *)getDate;
@end