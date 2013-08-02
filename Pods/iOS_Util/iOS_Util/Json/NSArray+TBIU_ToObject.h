//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-1-28 下午12:36.
//


#import <Foundation/Foundation.h>
#import "TBIUToObject.h"

@interface NSArray (TBIU_ToObject) <TBIUToObject>

- (id)toObjectWithClass:(Class)class;

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth;

@end