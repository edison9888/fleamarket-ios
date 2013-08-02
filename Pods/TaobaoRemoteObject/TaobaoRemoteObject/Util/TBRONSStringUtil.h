//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 下午3:15.
//


#import <Foundation/Foundation.h>


@interface TBRONSStringUtil : NSObject

+ (BOOL)isBlank:(NSString *)str;

+ (BOOL)isNotBlank:(NSString *)str;

+ (NSString *)safeConvertString:(id)value;
@end