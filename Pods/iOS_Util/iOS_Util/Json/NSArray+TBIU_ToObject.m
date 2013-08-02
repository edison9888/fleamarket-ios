//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-1-28 下午12:36.
//


#import "NSArray+TBIU_ToObject.h"
#import "NSDictionary+TBIU_ToObject.h"


@implementation NSArray (TBIU_ToObject)

- (id)toObjectWithClass:(Class)class {
    return [self toObjectWithClass:class withDepth:8];
}

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [array addObject:[obj toObjectWithClass:class withDepth:depth]];
        } else {
            [array addObject:obj];
        }
    }
    return array;
}
@end