//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMUserCommand.h"
#import "TBMBGlobalFacade.h"
#import "FMUserDO.h"
#import "FMUserService.h"


@implementation FMUserCommand {

}

+ (void)$$getIdleUserInfo:(id <TBMBNotification>)notification {
    [FMUserService getIdleUserInfo:^(BOOL isSuccess, FMUserDO *user) {
        if (isSuccess) {
            TBMBGlobalSendTBMBNotification([notification createNextNotificationForSEL:@selector
            ($$receiveIdleUserInfo:user:)                                    withBody:user]
            );
        }
    }];
}
@end