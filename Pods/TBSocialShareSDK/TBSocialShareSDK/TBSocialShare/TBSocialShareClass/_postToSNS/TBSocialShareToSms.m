//
// Created by yuanxiao on 13-5-30.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MessageUI/MessageUI.h>
#import "TBSocialShareToSms.h"
#import "TBSocialShareBaseModel.h"


@interface TBSocialShareToSms () <MFMessageComposeViewControllerDelegate>

@end

@implementation TBSocialShareToSms {

}

+ (TBSocialShareToSms *)instance {
    static TBSocialShareToSms *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareToSms;

    dispatch_once(&_oncePredicate_TBSocialShareToSms, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    if([MFMessageComposeViewController canSendText]) {
        controller.body = baseModel.status;
        [[UIApplication sharedApplication].keyWindow.rootViewController
                presentViewController:controller
                             animated:YES
                           completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"您的设备不支持发短信功能"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - messageComposeDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:YES];
    switch ( result ) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareSuccess:result:)]) {
                [self.shareResultDelegate socialShareSuccess:TBSocialShareTypeSina result:nil];
            }
            break;
        case MessageComposeResultSent:
            if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareFailed:error:)]) {
                [self.shareResultDelegate socialShareFailed:TBSocialShareTypeSina error:nil];
            }
            break;
        default:
            break;
    }
}


@end