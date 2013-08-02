//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-1-28 下午12:42.
//


@protocol TBIUToObject <NSObject>
- (id)toObjectWithClass:(Class)class;

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth;
@end