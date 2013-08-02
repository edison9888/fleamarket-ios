//
// Created by yuanxiao on 13-7-2.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MBMvc/TBMBSimpleStaticCommand.h>


@interface FMNotificationCommand : TBMBSimpleStaticCommand

+ (void)fromUrl:(NSURL *)url;

+ (void)toDetail:(NSURL *)url;

+ (void)toSearch:(NSURL *)url;

+ (void)fromPush:(NSString *)key;

@end