//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 下午3:15.
//


#import "TBRONSStringUtil.h"


@implementation TBRONSStringUtil {

}

+ (BOOL)isWhiteSpace:(unichar)ch {
    return [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch];
}

+ (BOOL)isBlank:(NSString *)str {
    NSUInteger strLen;
    if (str == nil || (strLen = str.length) == 0) {
        return YES;
    }
    for (NSUInteger i = 0; i < strLen; i++) {
        if (![self isWhiteSpace:[str characterAtIndex:i]]) {
            return NO;
        }
    }

    return YES;
}

+ (BOOL)isNotBlank:(NSString *)str {
    return ![self isBlank:str];
}


+ (NSString *)safeConvertString:(NSString *)value {
    return value == nil ? @"" : value;
}


@end