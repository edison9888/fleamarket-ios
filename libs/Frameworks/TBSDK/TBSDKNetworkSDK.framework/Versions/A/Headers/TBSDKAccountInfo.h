//
//  TBSDKSession.h
//  TBSDKNetworkSDK
//
//  Created by 亿刀 iTeam on 13-4-7.
//  Copyright (c) 2013年 亿刀 Iteam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTBSDKNetworkSDKAppToken                @"kTBSDKNetworkSDKAppToken"
#define kTBSDKNetworkSDKPubkey                  @"kTBSDKNetworkSDKPubkey"
#define kTBSDKNetworkSDKTopSession              @"kTBSDKNetworkSDKTopSession"
#define kTBSDKNetworkSDKSid                     @"kTBSDKNetworkSDKSid"
#define kTBSDKNetworkSDKNick                    @"kTBSDKNetworkSDKNick"
#define kTBSDKNetworkSDKUserId                  @"kTBSDKNetworkSDKUserId"
#define kTBSDKNetworkSDKLoginToken              @"kTBSDKNetworkSDKLoginToken"
#define kTBSDKNetworkSDKEcode                   @"kTBSDKNetworkSDKEcode"
#define kTBSDKNetworkSDKLogintime               @"kTBSDKNetworkSDKLogintime"
#define kTBSDKNetworkSDKCookies                 @"kTBSDKNetworkSDKCookies"


@interface TBSDKAccountInfo : NSObject

@property (nonatomic, strong) NSString                                          *appToken;
@property (nonatomic, strong) NSString                                          *pubkey;
@property (nonatomic, strong) NSString                                          *topSession;
@property (nonatomic, strong) NSString                                          *sid;
@property (nonatomic, strong) NSString                                          *nick;
@property (nonatomic, strong) NSString                                          *userId;
@property (nonatomic, strong) NSString                                          *loginToken;
@property (nonatomic, strong) NSString                                          *ecode;
@property (nonatomic, strong) NSString                                          *logintime;
@property (nonatomic, strong) id                                                cookies;

+ (TBSDKAccountInfo *)shareInstance;

- (void)clearAccountInfo;

@end
