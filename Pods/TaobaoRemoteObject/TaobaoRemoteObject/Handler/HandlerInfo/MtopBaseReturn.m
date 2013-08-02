//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 下午1:20.
//


#import "MtopBaseReturn.h"
#import "NSObject+TBIU_ToJson.h"


@implementation MtopBaseReturn {

@private
    NSString *_api;
    NSString *_v;
    id _data;
    NSArray *_ret;
}
@synthesize api = _api;
@synthesize v = _v;
@synthesize data = _data;
@synthesize ret = _ret;


- (NSUInteger)retCount {
    return _ret ? [_ret count] : 0;
}

- (NSString *)getRetCodeAtIndex:(NSUInteger)index {
    if (index < [self retCount]) {
        NSString *ret = [_ret objectAtIndex:index];
        NSArray *separatedByString = [ret componentsSeparatedByString:@"::"];
        if ([separatedByString count] > 0) {
            return [separatedByString objectAtIndex:0];
        }
    }
    return nil;
}

- (NSString *)getRetMessageAtIndex:(NSUInteger)index {
    if (index < [self retCount]) {
        NSString *ret = [_ret objectAtIndex:index];
        NSArray *separatedByString = [ret componentsSeparatedByString:@"::"];
        if ([separatedByString count] > 1) {
            return [separatedByString objectAtIndex:1];
        }
    }
    return nil;
}

- (NSString *)description {
    return [self toJSONString];
}
@end