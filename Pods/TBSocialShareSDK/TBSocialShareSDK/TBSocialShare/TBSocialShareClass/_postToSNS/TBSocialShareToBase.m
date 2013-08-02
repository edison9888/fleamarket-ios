//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareToBase.h"
#import "TBSocialShareManager.h"
#import "WXApi.h"
#import "TBSocialShareBaseModel.h"


@implementation TBSocialShareToBase {

@private
    __weak id <TBSocialShareResultProtocol> _shareResultDelegate;
}
@synthesize shareResultDelegate = _shareResultDelegate;

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {

}

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate{
    return NO;
}

- (void)login {

}

- (void)logout {

}

- (BOOL)isLogin {
    return NO;
}

@end