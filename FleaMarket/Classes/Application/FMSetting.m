//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 下午2:10.
//


#import "FMSetting.h"


@implementation FMSetting {
}


- (id)init {
    self = [super init];
    if (self) {
        self.isPostItemInWifi = YES;
        self.isAutoImageCompress = YES;
        self.isOpenHeadPhone = NO;
    }
    return self;
}

@end