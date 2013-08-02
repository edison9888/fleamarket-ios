//
// Created by yuanxiao on 13-6-5.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareToDouban.h"
#import "GTDouban.h"
#import "TBSocialShareBaseModel.h"
#import "SFHFKeychainUtils.h"


@interface TBSocialShareToDouban () <GTDoubanDelegate>

@end

@implementation TBSocialShareToDouban {
@private
    GTDouban *_douban;
    TBSocialShareBaseModel *_baseModel;
}

+ (TBSocialShareToDouban *)instance {
    static TBSocialShareToDouban *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareToDouban;

    dispatch_once(&_oncePredicate_TBSocialShareToDouban, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _douban = [[GTDouban alloc] initWithAppKey:[TBSocialShareConfig instance].tbDoubanAppKey
                                         appSecret:[TBSocialShareConfig instance].tbDoubanAppSecret
                                    appRedirectURI:[TBSocialShareConfig instance].tbDoubanAppRedirectURI
                                       andDelegate:self];
    }
    return self;
}

- (void)dealloc {
    _douban.delegate = nil;
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {
    if ([_douban isLoggedIn]) {
        [self sendStatus:baseModel];
    } else {
        _baseModel = baseModel;
        [_douban logIn];
    }
}

- (void)sendStatus:(TBSocialShareBaseModel *)baseModel {
    if (baseModel.image) {
        [_douban sendWeiBoWithText:baseModel.status imageData:UIImageJPEGRepresentation(baseModel.image, 0.9)];
    } else {
        [_douban sendWeiBoWithText:baseModel.status];
    }
}

- (void)login {
    [_douban logIn];
}

- (void)logout {
    [_douban logOut];
}

- (BOOL)isLogin {
    return [_douban isLoggedIn];
}

#pragma mark -- GTDoubanDelegate
- (void)engineDidLogIn:(GTDouban *)engine {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(loginSuccess:)]) {
        [self.shareResultDelegate loginSuccess:TBSocialShareTypeDouban];
    }
    if (_baseModel) {
        [self sendStatus:_baseModel];
    }
}

- (void)engine:(GTDouban *)engine didFailToLogInWithError:(NSError *)error {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(loginFailed:error:)]) {
        [self.shareResultDelegate loginFailed:TBSocialShareTypeDouban error:error];
    }
}

- (void)engineDidLogOut:(GTDouban *)engine {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(logoutSuccess:)]) {
        [self.shareResultDelegate logoutSuccess:TBSocialShareTypeDouban];
    }
}

- (void)engine:(GTDouban *)engine requestDidFailWithError:(NSError *)error {
    if (![_douban isAuthorizeExpired])
        return;

    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareFailed:error:)]) {
        [self.shareResultDelegate socialShareFailed:TBSocialShareTypeDouban error:error];
    }
}

- (void)engine:(GTDouban *)engine requestDidSucceedWithResult:(id)result {
    if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareSuccess:result:)]) {
        [self.shareResultDelegate socialShareSuccess:TBSocialShareTypeDouban result:result];
    }
    _baseModel = nil;
}



@end