//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午2:01.
//


#import <Foundation/Foundation.h>

@interface NSObject (TBIU_ToJson)

- (NSString *)toJSONString;

- (NSData *)toJSONData;

- (NSString *)toJSONStringWithDepth:(NSUInteger)depth;

- (NSData *)toJSONDataWithDepth:(NSUInteger)depth;

@end