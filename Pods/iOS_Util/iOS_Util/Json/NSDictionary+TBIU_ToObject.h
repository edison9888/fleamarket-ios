//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午7:39.
//


#import <Foundation/Foundation.h>
#import "TBIUToObject.h"

@interface NSDictionary (TBIU_ToObject) <TBIUToObject>

- (id)toObjectWithClass:(Class)class;

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth;

- (id)toObjectWithExistObject:(id)obj;

- (id)toObjectWithExistObject:(id)obj withDepth:(NSUInteger)depth;

@end