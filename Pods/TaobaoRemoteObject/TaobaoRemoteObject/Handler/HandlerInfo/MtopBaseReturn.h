//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 下午1:20.
//


#import <Foundation/Foundation.h>


@interface MtopBaseReturn : NSObject

@property(copy, nonatomic) NSString *api;
@property(copy, nonatomic) NSString *v;
@property(strong, nonatomic) id data;
@property(strong, nonatomic) NSArray *ret;

- (NSUInteger)retCount;

- (NSString *)getRetCodeAtIndex:(NSUInteger)index;

- (NSString *)getRetMessageAtIndex:(NSUInteger)index;

@end