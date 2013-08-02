//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-11 下午4:34.
//


#import "MppHandler.h"


@implementation MppHandler {

}
+ (MppHandler *)instance {
    static MppHandler *_instance = nil;
    static dispatch_once_t _oncePredicate_MppHandler;

    dispatch_once(&_oncePredicate_MppHandler, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}
@end