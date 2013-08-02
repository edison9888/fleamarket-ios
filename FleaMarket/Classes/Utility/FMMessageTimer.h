//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-30 上午9:04.
//


#import <Foundation/Foundation.h>

@interface FMMessageTimer : NSObject

+ (FMMessageTimer *)instance;

- (void)initFMMessageTimer;

//立马做一次请求
- (void)fire;

@end