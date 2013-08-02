//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMMessageCommand.h"
#import "TBMBGlobalFacade.h"
#import "FMMessageService.h"
#import "FMPushService.h"
#import "FMRemoteMessage.h"
#import "FMMessageDAO.h"
#import "FMMessageInfo.h"
#import "FMMessageParameter.h"

@implementation FMMessageCommand {

}

#define MAX_GET_NUM   (30)

static void getMessageRecursion() {
    [FMPushService getNewPush:MAX_GET_NUM
                          ret:^(NSUInteger retCount, NSArray *msg_ids) {
                              NSString *messageIds = [msg_ids componentsJoinedByString:@","];
                              FMLOG(@"messageIds:[%@]", messageIds);
                              [FMPushService getContentPush:msg_ids
                                                        ret:^(NSArray *contents) {
                                                            for (FMRemoteMessage *o in contents) {
                                                                [[FMMessageDAO instance]
                                                                        insertMessageInfo:[o toFMMessageInfo]
                                                                                   result:NULL];
                                                            }
                                                            if (retCount >= MAX_GET_NUM) {
                                                                getMessageRecursion();
                                                            } else {
                                                                TBMBGlobalSendNotificationForSELWithBody(@selector($$hasNewMessage:isSync:),
                                                                        [NSNumber numberWithBool:NO]
                                                                );
                                                            }
                                                        }];
                          }];
}

+ (void)$$getNewMessage:(id <TBMBNotification>)notification {
    getMessageRecursion();
}

+ (void)$$getMessageUnreadCount:(id <TBMBNotification>)notification {
    [FMMessageService countUnread:^(NSNumber *result) {
        TBMBGlobalSendNotificationForSELWithBody(@selector($$receiveMessageUnreadCount:count:), result);
    }];
}

+ (void)$$deleteMessage:(id <TBMBNotification>)notification withParameter:(FMMessageParameter *)parameter {
    [FMMessageService deleteMessageByType:parameter.type
                                   itemId:parameter.itemId
                               reporterId:parameter.reporterId
                                   result:^(NSNumber *number) {
                                       TBMBGlobalSendNotificationForSEL(@selector($$hasClearMessageUnreadCount:));
                                   }];
}

+ (void)$$clearMessageUnreadCount:(id <TBMBNotification>)notification {
    [FMMessageService clearUnreadWithResult:^(NSNumber *result) {
        if ([result boolValue]) {
            TBMBGlobalSendNotificationForSEL(@selector($$hasClearMessageUnreadCount:));
        }
    }];
}

@end