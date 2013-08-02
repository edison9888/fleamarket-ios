//
// Created by yuanxiao on 13-5-29.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define TB_SOCIAL_SCREEN_HEIGHT ((float)[[UIScreen mainScreen] bounds].size.height)
#define TB_SOCIAL_SCREEN_WIDTH ((float)[[UIScreen mainScreen] bounds].size.width)

typedef enum {
    TBSocialShareTypeNone,
    TBSocialShareTypeSina,
    TBSocialShareTypeWeChat,
    TBSocialShareTypeWeChatFriend,
    TBSocialShareTypeDouban,
    TBSocialShareTypeEmail,
    TBSocialShareTypeSms
} TBSocialShareType;

@interface TBSocialShareConfig : NSObject

@property (nonatomic, copy) NSString *tbSinaAppKey;
@property (nonatomic, copy) NSString *tbSinaAppSecret;
@property (nonatomic, copy) NSString *tbSinaAppRedirectURI;


@property (nonatomic, copy) NSString *tbWeChatAppID;

@property (nonatomic, copy) NSString *tbDoubanAppKey;
@property (nonatomic, copy) NSString *tbDoubanAppSecret;
@property (nonatomic, copy) NSString *tbDoubanAppRedirectURI;

@property (nonatomic, assign) BOOL isCloseWeiBoSSO;

+ (TBSocialShareConfig *)instance;


@end