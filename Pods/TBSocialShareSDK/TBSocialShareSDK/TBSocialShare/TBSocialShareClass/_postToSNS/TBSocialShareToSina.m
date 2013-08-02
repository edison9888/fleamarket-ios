//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareToSina.h"
#import "TBSocialShareSinaModel.h"
#import "TBSocialShareConfig.h"
#import "SFHFKeychainUtils.h"


@interface TBSocialShareToSina () <SinaWeiboDelegate, SinaWeiboRequestDelegate>
@end

@implementation TBSocialShareToSina {
@private
    SinaWeibo              *_sinaWeibo;
    NSMutableDictionary    *_data;
}

+ (TBSocialShareToSina *)instance {
    static TBSocialShareToSina *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareToSina;

    dispatch_once(&_oncePredicate_TBSocialShareToSina, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:[TBSocialShareConfig instance].tbSinaAppKey
                                             appSecret:[TBSocialShareConfig instance].tbSinaAppSecret
                                        appRedirectURI:[TBSocialShareConfig instance].tbSinaAppRedirectURI
                                           andDelegate:self];
    }
    return self;
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {
    if (baseModel.image) {
        [self postToSina:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%@", baseModel.status], @"status",
                baseModel.image, @"pic", nil]];
    } else if (baseModel.status && ![baseModel.status isEqualToString:@""]) {
        [self postToSina:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                baseModel.status, @"status", nil]];
    }
}


- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate {
    return [_sinaWeibo handleOpenURL:url];
}

- (void)postToSina:(NSMutableDictionary *)data {
    if ([_sinaWeibo isLoggedIn]) {
        NSString *url = data.count == 1 ? @"statuses/update.json" : @"statuses/upload.json";
        [_sinaWeibo requestWithURL:url
                            params:data
                        httpMethod:@"POST"
                          delegate:self];
    } else {
        [_sinaWeibo logIn];
        _data = data;
    }
}

- (void)dealloc {
    _sinaWeibo.delegate = nil;
}

- (void)login {
    [_sinaWeibo logIn];
}

- (void)logout {
    [_sinaWeibo logOut];
}

- (BOOL)isLogin {
    return [_sinaWeibo isLoggedIn];
}

#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(loginSuccess:)]) {
        [self.shareResultDelegate loginSuccess:TBSocialShareTypeSina];
    }
    if (_data) {
        [self postToSina:_data];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(logoutSuccess:)]) {
        [self.shareResultDelegate logoutSuccess:TBSocialShareTypeSina];
    }
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo {
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(loginFailed:error:)]) {
        [self.shareResultDelegate loginFailed:TBSocialShareTypeSina error:error];
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    [_sinaWeibo logIn];
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error {
    if (![_sinaWeibo isAuthValid])
        return;

    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareFailed:error:)]) {
        [self.shareResultDelegate socialShareFailed:TBSocialShareTypeSina error:error];
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareSuccess:result:)]) {
        [self.shareResultDelegate socialShareSuccess:TBSocialShareTypeSina result:result];
    }
    _data = nil;
}



@end