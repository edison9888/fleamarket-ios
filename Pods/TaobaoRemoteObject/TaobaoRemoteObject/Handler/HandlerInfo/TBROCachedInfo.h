//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 上午10:05.
//


#import <Foundation/Foundation.h>


@interface TBROCachedInfo : NSObject
@property(nonatomic, assign) NSTimeInterval cacheTime;

- (NSString *)description;
@end