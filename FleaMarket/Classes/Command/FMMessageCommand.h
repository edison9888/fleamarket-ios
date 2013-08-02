//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MBMvc/TBMBSimpleStaticCommand.h>

@class FMMessageParameter;


@interface FMMessageCommand : TBMBSimpleStaticCommand

+ (void)$$getNewMessage:(id <TBMBNotification>)notification;

+ (void)$$getMessageUnreadCount:(id <TBMBNotification>)notification;


+ (void)$$deleteMessage:(id <TBMBNotification>)notification withParameter:(FMMessageParameter *)parameter;

+ (void)$$clearMessageUnreadCount:(id <TBMBNotification>)notification;

@end