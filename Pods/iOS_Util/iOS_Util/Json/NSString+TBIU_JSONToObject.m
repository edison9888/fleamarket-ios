//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 上午11:38.
//


#import "NSString+TBIU_JSONToObject.h"
#import "NSDictionary+TBIU_ToObject.h"
#import "TBIUJson.h"


@implementation NSString (TBIU_JSONToObject)
- (id)jsonToObjectWithClass:(Class)class {
    return [self jsonToObjectWithClass:class
                             withDepth:8];
}

- (id)jsonToObjectWithClass:(Class)class withDepth:(NSUInteger)depth {
    NSError *error = nil;
    id object = TBIUJSONDecode([self dataUsingEncoding:NSUTF8StringEncoding], &error);
    return [self idToObjectWithClass:class
                          jsonObject:object];
}

- (id)idToObjectWithClass:(Class)class jsonObject:(id)jsonObject {
    if (jsonObject != nil && [jsonObject isKindOfClass:[NSDictionary class]]) {
        return [jsonObject toObjectWithClass:class];
    } else if (jsonObject != nil && [jsonObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[(NSArray *) jsonObject count]];
        for (id inJsonObject in jsonObject) {
            id o = [self idToObjectWithClass:class
                                  jsonObject:inJsonObject];
            if (o) [ret addObject:o];
        }
        return ret;
    }
    return nil;
}

@end