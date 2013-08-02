//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午12:09.
//


#import <Foundation/Foundation.h>

@interface NSObject (TBIU_ToNSDictionary)

- (id)toDictionaryOrArray;

- (id)toDictionaryOrArrayWithDepth:(NSUInteger)depth;


@end