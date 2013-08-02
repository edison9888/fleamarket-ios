//
// Created by yuanxiao on 13-5-30.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MessageUI/MessageUI.h>
#import "TBSocialShareToMail.h"
#import "TBSocialShareMailModel.h"

@interface TBSocialShareToMail () <MFMailComposeViewControllerDelegate>

@end

@implementation TBSocialShareToMail {

}

+ (TBSocialShareToMail *)instance {
    static TBSocialShareToMail *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareToMail;

    dispatch_once(&_oncePredicate_TBSocialShareToMail, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            [self displayComposeController:(TBSocialShareMailModel *)baseModel];
            return;
        }
        [self launchMailApp:(TBSocialShareMailModel *)baseModel];
        return;
    }
    [self launchMailApp:(TBSocialShareMailModel *)baseModel];
}

- (void)displayComposeController:(TBSocialShareMailModel *)mailModel {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:mailModel.title];
    NSString *body = mailModel.status ? : [self getMailMessageBody:mailModel];
    [mailComposeViewController setMessageBody:body isHTML:NO];
    if (mailModel.attachment && mailModel.attachment.length > 0) {
        [mailComposeViewController addAttachmentData:mailModel.attachment
                                            mimeType:@""
                                            fileName:mailModel.fileName];
    }
    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:mailModel.suggestionMail]];
    [[UIApplication sharedApplication].keyWindow.rootViewController
            presentViewController:mailComposeViewController
                         animated:YES
                       completion:nil];
}


- (NSString *)getMailMessageBody:(TBSocialShareMailModel *)mailModel {
    __autoreleasing NSMutableString *message = [[NSMutableString alloc] init];
    [message appendString:@"\n\n\n\n\n\n\n\n"];
    [message appendString:[NSString stringWithFormat:@"设备:%@\n",[self getModel]]];
    [message appendString:[NSString stringWithFormat:@"系统:%@\n",[[UIDevice currentDevice] systemVersion]]];
    [message appendString:[NSString stringWithFormat:@"客户端版本:%@\n",mailModel.appVersion]];
    [message appendString:[NSString stringWithFormat:@"TTID:%@\n", mailModel.currentTTID]];
    return message;
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    if ([sDeviceModel isEqual:@"i386"]) return @"Simulator";  //iPhone Simulator
    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone4 AT&T";  //iPhone 4 - AT&T
    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone4 Other";  //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPhone5,1"]) return @"iPhone5";    //iPhone 5 (GSM)
    if ([sDeviceModel isEqual:@"iPod1,1"]) return @"iPod1stGen"; //iPod Touch 1G
    if ([sDeviceModel isEqual:@"iPod2,1"]) return @"iPod2ndGen"; //iPod Touch 2G
    if ([sDeviceModel isEqual:@"iPod3,1"]) return @"iPod3rdGen"; //iPod Touch 3G
    if ([sDeviceModel isEqual:@"iPod4,1"]) return @"iPod4thGen"; //iPod Touch 4G
    if ([sDeviceModel isEqual:@"iPad1,1"]) return @"iPadWiFi";   //iPad Wifi
    if ([sDeviceModel isEqual:@"iPad1,2"]) return @"iPad3G";     //iPad 3G
    if ([sDeviceModel isEqual:@"iPad2,1"]) return @"iPad2";      //iPad 2 (WiFi)
    if ([sDeviceModel isEqual:@"iPad2,2"]) return @"iPad2";      //iPad 2 (GSM)
    if ([sDeviceModel isEqual:@"iPad2,3"]) return @"iPad2";      //iPad 2 (CDMA)
    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
//If a newer version exist
    if ([aux rangeOfString:@"iPhone"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
        if (version == 3) return @"iPhone4";
        else if (version >= 4 && version < 5) return @"iPhone4s";
        else if (version >= 5) return @"iPhone5";
    }
    if ([aux rangeOfString:@"iPod"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
        if (version >= 4 && version < 5) return @"iPod4thGen"; else if (version >= 5) return @"iPod5thGen";
    }
    if ([aux rangeOfString:@"iPad"].location != NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
        if (version == 1) return @"iPad3G";
        if (version >= 2 && version < 3) return @"iPad2"; else if (version >= 3)return @"new iPad";
    }
    //If none was found, send the original string
    return sDeviceModel;
}

- (void)launchMailApp:(TBSocialShareMailModel *)mailModel {
    NSURL *mailURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", mailModel.suggestionMail]];
    [[UIApplication sharedApplication]openURL:mailURL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareSuccess:result:)]) {
                [self.shareResultDelegate socialShareSuccess:TBSocialShareTypeSina result:nil];
            }
            break;
        case MFMailComposeResultFailed:
            if (self.shareResultDelegate && [self.shareResultDelegate respondsToSelector:@selector(socialShareFailed:error:)]) {
                [self.shareResultDelegate socialShareFailed:TBSocialShareTypeSina error:error];
            }
            break;
        default:
            break;
    }

    [controller dismissModalViewControllerAnimated:YES];
}

@end