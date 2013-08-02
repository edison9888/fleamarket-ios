//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午2:01.
//


#import "NSObject+TBIU_ToJson.h"
#import "NSObject+TBIU_ToNSDictionary.h"
#import "TBIUJson.h"


@implementation NSObject (TBIU_ToJson)
- (NSString *)toJSONString {
    return [self toJSONStringWithDepth:8];
}

- (NSData *)toJSONData {
    return [self toJSONDataWithDepth:8];
}

- (NSString *)toJSONStringWithDepth:(NSUInteger)depth {
    return [[NSString alloc]
                      initWithData:[self toJSONDataWithDepth:depth]
                          encoding:NSUTF8StringEncoding];
}

- (NSData *)toJSONDataWithDepth:(NSUInteger)depth {
    NSError *error = nil;
    return TBIUJSONEncode([self toDictionaryOrArrayWithDepth:depth], &error);
}


@end