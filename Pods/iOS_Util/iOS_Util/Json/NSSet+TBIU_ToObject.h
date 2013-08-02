//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-1-28 下午12:41.
//


#import <Foundation/Foundation.h>
#import "TBIUToObject.h"

@interface NSSet (TBIU_ToObject) <TBIUToObject>
- (id)toObjectWithClass:(Class)class;

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth;
@end