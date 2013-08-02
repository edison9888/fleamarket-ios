//
// Created by yuanxiao on 13-5-29.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareConfig.h"


@implementation TBSocialShareConfig {

@private
    NSString *_tbSinaAppKey;
    NSString *_tbSinaAppSecret;
    NSString *_tbSinaAppRedirectURI;
    NSString *_tbWeChatAppID;
    NSString *_tbDoubanAppKey;
    NSString *_tbDoubanAppSecret;
    NSString *_tbDoubanAppRedirectURI;
}

@synthesize tbSinaAppKey = _tbSinaAppKey;
@synthesize tbSinaAppSecret = _tbSinaAppSecret;
@synthesize tbSinaAppRedirectURI = _tbSinaAppRedirectURI;
@synthesize tbWeChatAppID = _tbWeChatAppID;

@synthesize tbDoubanAppKey = _tbDoubanAppKey;
@synthesize tbDoubanAppSecret = _tbDoubanAppSecret;
@synthesize tbDoubanAppRedirectURI = _tbDoubanAppRedirectURI;

+ (TBSocialShareConfig *)instance {
    static TBSocialShareConfig *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareConfig;

    dispatch_once(&_oncePredicate_TBSocialShareConfig, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

@end