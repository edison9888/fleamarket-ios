//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-28 上午10:57.
//


#import <Foundation/Foundation.h>

@interface NSString (TBHelper)

/*
 * Returns the MD5 value of the string
 */
- (NSString *)md5;

/*
 * Returns the SHA1 value of the string
 */
- (NSString *)SHA1;

- (NSString *)makeURLEncode:(int)stringEncoding;

@end