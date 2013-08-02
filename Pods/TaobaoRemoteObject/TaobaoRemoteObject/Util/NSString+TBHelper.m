//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-28 上午10:57.
//


#import "NSString+TBHelper.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (TBHelper)

- (NSString *)md5 {
    const char *str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

- (NSString *)SHA1 {
    const char *cstr = [self UTF8String];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}


- (NSString *)makeURLEncode:(int)stringEncoding {
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            (__bridge CFStringRef) self, NULL,
            CFSTR("!*'();:@&=+$,/?%#[]"),
            stringEncoding);
    return result;
}


@end