//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-6 上午9:17.
//


#import <Foundation/Foundation.h>


@interface FMCustomStatusBar : UIWindow
- (void)showStatusMessage:(NSString *)message;

- (void)hide;

+ (void)showStatusMessage:(NSString *)message hideAfter:(NSTimeInterval)time;
@end