//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMUserDO;


@interface FMUserService : FMBaseService

+ (void)getIdleUserInfo:(void (^)(BOOL, FMUserDO *))result;

+ (void)getUserFlagWithNick:(NSString *)userNick result:(void (^)(NSArray *))result;

+ (NSString *)getUserRate:(NSInteger)rate
                  isBuyer:(BOOL)isBuyer;

+ (void)getUserInfo:(NSString *)nick
            success:(void (^)(id data))success
             failed:(void (^)(NSString *error))failed;

@end