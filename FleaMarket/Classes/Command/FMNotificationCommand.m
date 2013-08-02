//
// Created by yuanxiao on 13-7-2.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import "FMNotificationCommand.h"
#import "FMLoginService.h"
#import "TBIUJson.h"
#import "FMWindowShower.h"


@implementation FMNotificationCommand {

}

+ (void)fromUrl:(NSURL *)url {
    if (url) {
        NSString *type = [url host];
        if ([type isEqualToString:@"item"]) {
            [self toDetail:url];
        } else if ([type isEqualToString:@"search"]) {
            [self toSearch:url];
        }
    }

}

+ (void)toDetail:(NSURL *)url {
    NSString *type = [url host];
    if ([type isEqualToString:@"item"]) {
        NSString *id = [url lastPathComponent];
        if ([id longLongValue] > 0) {
            [self performSelector:@selector(toDetailWithId:)
                       withObject:id
                       afterDelay:0.5];
        }
    }
}

+ (void)toDetailWithId:(id)itemId {
    [[[FMWindowShower instance] proxyObject] gotoDetailWithId:itemId];
}

+ (void)toSearch:(NSURL *)url {
    NSString *type = [url host];
    if ([type isEqualToString:@"search"]) {
        NSString *searchCondition = [url lastPathComponent];
        NSDictionary *parameter = TBIUJSONDecode([searchCondition dataUsingEncoding:NSUTF8StringEncoding], NULL);
        [self performSelector:@selector(toSearchWithParameter:)
                   withObject:parameter
                   afterDelay:0.5];
    }

}

+ (void)toSearchWithParameter:(id)parameter {
    [[[FMWindowShower instance] proxyObject]
                      gotoSearch:parameter];
}

+ (void)fromPush:(NSString *)key {
    [[FMLoginService proxyObject] autoLogin:^(FMLoginResponse *loginResponse) {
        [[[FMWindowShower instance] proxyObject]
                          goToMessageView:loginResponse.isSuccess
                                  withKey:key];
    }];
}

@end