//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-16 下午1:16.
//

#import <Foundation/Foundation.h>

@interface FMPostRet : NSObject

@property(retain, nonatomic) NSNumber *itemId;
@property(copy, nonatomic) NSString *shareText;
@property(assign, nonatomic) BOOL disableEdit;

- (BOOL)hasShareText;

@end