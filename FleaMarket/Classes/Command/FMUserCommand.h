//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MBMvc/TBMBSimpleStaticCommand.h>


@interface FMUserCommand : TBMBSimpleStaticCommand

+ (void)$$getIdleUserInfo:(id <TBMBNotification>)notification;

@end