//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareManager.h"
#import "TBSocialShareToSina.h"
#import "TBSocialShareToWeChat.h"
#import "TBSocialShareBaseModel.h"
#import "WXApi.h"
#import "TBSocialShareToMail.h"
#import "TBSocialShareToSms.h"
#import "TBSocialShareToDouban.h"



@implementation TBSocialShareManager {
}

+ (TBSocialShareManager *)instance {
    static TBSocialShareManager *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareManager;

    dispatch_once(&_oncePredicate_TBSocialShareManager, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate {
    return [[TBSocialShareManager instance] handleOpenURL:url delegate:delegate];
}

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate {
    if ([url.description hasPrefix:@"sinaweibosso"]) {
        return [[TBSocialShareToSina instance] handleOpenURL:url delegate:delegate];
    }
    else if([url.description hasPrefix:@"wx"]){
        return [[TBSocialShareToWeChat instance]  handleOpenURL:url delegate:delegate];
    }
    return NO;
}

+ (void)registerApp {
    //向微信注册
    [WXApi registerApp:[TBSocialShareConfig instance].tbWeChatAppID];
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel
           shareType:(TBSocialShareType)shareType
            delegate:(id<TBSocialShareResultProtocol>)delegate {
    [[self getShareToBase:shareType delegate:delegate] shareContent:baseModel];
}

- (void)loginWithShareType:(TBSocialShareType)shareType delegate:(id<TBSocialShareResultProtocol>)delegate {
    [[self getShareToBase:shareType delegate:delegate] login];
}

- (void)logoutWithShareType:(TBSocialShareType)shareType delegate:(id<TBSocialShareResultProtocol>)delegate {
    [[self getShareToBase:shareType delegate:delegate] logout];
}

- (BOOL)isLoginWithShareType:(TBSocialShareType)shareType {
    return [[self getShareToBase:shareType delegate:nil] isLogin];
}

- (BOOL)isWXAppInstalled {
    return [[TBSocialShareToWeChat instance] isWXAppInstalled];
}

- (TBSocialShareToBase *)getShareToBase:(TBSocialShareType)shareType delegate:(id<TBSocialShareResultProtocol>)delegate {
    TBSocialShareToBase *shareToBase = nil;
    switch (shareType) {
        case TBSocialShareTypeSina:
            shareToBase = [TBSocialShareToSina instance];
            break;

        case TBSocialShareTypeWeChat:
            shareToBase = [TBSocialShareToWeChat instance];
            ((TBSocialShareToWeChat *)shareToBase).wxScene = WXSceneSession;
            break;

        case TBSocialShareTypeWeChatFriend:
            shareToBase = [TBSocialShareToWeChat instance];
            ((TBSocialShareToWeChat *)shareToBase).wxScene = WXSceneTimeline;
            break;

        case TBSocialShareTypeDouban:
            shareToBase = [TBSocialShareToDouban instance];
            break;

        case TBSocialShareTypeEmail:
            shareToBase = [TBSocialShareToMail instance];
            break;

        case TBSocialShareTypeSms:
            shareToBase = [TBSocialShareToSms instance];
            break;

        default:
            break;
    }
    if (delegate) {
        shareToBase.shareResultDelegate = delegate;
    }
    return shareToBase;
}

@end