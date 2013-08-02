//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-1-28 下午12:41.
//


#import "NSSet+TBIU_ToObject.h"


@implementation NSSet (TBIU_ToObject)
- (id)toObjectWithClass:(Class)class {
    return [self toObjectWithClass:class withDepth:8];
}

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth {
    NSMutableSet *set = [NSMutableSet setWithCapacity:self.count];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [set addObject:[obj toObjectWithClass:class withDepth:depth]];
        } else {
            [set addObject:obj];
        }
    }
    return set;
}
@end