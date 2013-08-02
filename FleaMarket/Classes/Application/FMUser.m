//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午10:42.
//


#import "FMUser.h"
#import "NSString+Helper.h"


@implementation FMUser {

}

- (id)init {
    self = [super init];
    if (self) {
        self.isLogin = NO;
    }
    return self;
}

- (NSString *)headPicUrl {
    if ([_id length]) {
        return [NSString stringWithFormat:kApiHeadPortrait,
                                          _id];
    }
    return nil;
}

- (BOOL)isMyself:(NSString *)userId {
    if (!self.isLogin || ![userId isEqualToString:self.id]) {
        return NO;
    }
    return YES;
}

@end