//
//  TBSDKLoginConfiguration.h
//  TBSDKLoginSDK
//
//  Created by 亿刀 on 13-4-7.
//  Copyright (c) 2013年 亿刀. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBSDKLoginConfiguration : NSObject

@property (nonatomic, strong) NSString                                          *appToken;
@property (nonatomic, strong) NSString                                          *pubkey;
@property (nonatomic, strong) NSString                                          *topSession;
@property (nonatomic, strong) NSString                                          *sid;
@property (nonatomic, strong) NSString                                          *nick;
@property (nonatomic, strong) NSString                                          *userId;
@property (nonatomic, strong) NSString                                          *loginToken;
@property (nonatomic, strong) NSString                                          *ecode;
@property (nonatomic, strong) NSString                                          *logintime;

+ (TBSDKLoginConfiguration *)shareInstance;

@end
