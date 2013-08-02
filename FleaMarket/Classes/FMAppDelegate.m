//
//  HMAppDelegate.m
//  FleaMarket
//
//  Created by Henson on 05/21/13.
//  Copyright (c) 2013 taobao.com. All rights reserved.
//

#import <MBMvc/TBMBSimpleInstanceCommand+TBMBProxy.h>
#import <TaobaoRemoteObject/TBROSync.h>
#import <UserTrack/UT.h>
#import "FMAppDelegate.h"
#import "FMRootViewController.h"
#import "FMApplication.h"
#import "FMVoiceService.h"
#import "TBSocialShareManager.h"
#import "FMUserTrack.h"
#import "FMNotificationCommand.h"
#import "TBSDKPushCenterUserTrackEngine.h"
#import "FMPushService.h"
#import "FMMessageTimer.h"
#import "Reachability.h"
#import "FMCommon.h"
#import "FMGuideController.h"

static BOOL __start_open_url = NO;

@interface FMAppDelegate () <WXApiDelegate>
@end

@implementation FMAppDelegate {
@private
    Reachability *_reachability;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FMApplication instance] systemInit];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    FMRootViewController *rootViewController = [[FMRootViewController alloc] init];

    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_SHOW]) {
        FMGuideController *guideController = [[FMGuideController alloc] init];
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [rootViewController presentViewController:guideController
                                         animated:YES
                                       completion:nil];
    }

    [[FMApplication instance] applicationDidStart:launchOptions];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
            (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // listen network changed
    _reachability = [Reachability reachabilityForInternetConnection];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [_reachability stopNotifier];
    [[NSNotificationCenter defaultCenter]
                           removeObserver:self
                                     name:kReachabilityChangedNotification
                                   object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FMVoiceService proxyObject] stopPlayVoice];
    [[FMApplication instance] saveToPreference];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [_reachability startNotifier];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[FMMessageTimer instance] fire];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[FMApplication instance] destroy];
}

- (void)reachabilityChanged:(NSNotification *)notify {
    [[TBROSync instance] reSync];
    if ([_reachability currentReachabilityStatus] == NotReachable) {
        [FMCommon showToast:[UIApplication sharedApplication].keyWindow
                       text:@"亲，您好像没有连接到互联网哦！"];
    }
}

- (void)onReq:(BaseReq *)req {
    [FMUserTrack ctrlClicked:@"接受微信跳转到本客户端"
                      onPage:self];
    //
    if (req && [req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq *fromWXReq = (ShowMessageFromWXReq *) req;
        if (fromWXReq.message.mediaObject && [fromWXReq.message.mediaObject isKindOfClass:[WXAppExtendObject class]]) {
            WXAppExtendObject *ext = (WXAppExtendObject *) fromWXReq.message.mediaObject;
            if (ext.extInfo) {
                [self handleUrl:[NSURL URLWithString:ext.extInfo]];
            }
        }
    }
}

- (void)onResp:(BaseResp *)resp {
    //分享完回来的回调
    FMLOG(@"Share WX Return:%@", resp);
    if (resp.errCode == 0 && !resp.errStr) {
        [FMUserTrack ctrlClicked:@"微信发送成功"
                          onPage:self];
    } else {
        [FMUserTrack ctrlClicked:[NSString stringWithFormat:@"微信发送失败[%d][%@]",
                                                            resp.errCode,
                                                            resp.errStr ? : @""]
                          onPage:self];
    }

}

- (void)handleUrl:(NSURL *)url {
    [FMUserTrack ctrlClicked:@"由URL跳转到本客户端"
                      onPage:self];
    if (url) {
        [FMNotificationCommand fromUrl:url];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    FMLOG(@"handleOpenURL:%@", url);
    if ([[url scheme] isEqualToString:TBWeChatAppID]
            || [[url scheme] hasSuffix:TBSinaAppKey]) {
        [TBSocialShareManager handleOpenURL:url
                                   delegate:self];
    }
    if (__start_open_url) {
        __start_open_url = NO;
        return YES;
    }
    [self handleUrl:url];
    return YES;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    FMLOG(@"openURL:%@", url);
    if ([[url scheme] isEqualToString:TBWeChatAppID]
            || [[url scheme] hasSuffix:TBSinaAppKey]) {
        return [TBSocialShareManager handleOpenURL:url
                                          delegate:self];
    }
    if (__start_open_url) {
        __start_open_url = NO;
        return YES;
    }
    [self handleUrl:url];
    return YES;
}

#pragma mark - push
//推送通知使用方法
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *pushToken = [[devToken description]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];

    FMLOG(@"token = %@", pushToken);
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" "
                                                     withString:@""];
    FMLOG(@"pushToken= %@", pushToken);
    [FMPushService registerDeviceToken:devToken];

    [UT bindPageName:
                [NSDictionary dictionaryWithObjectsAndKeys:@"启动用户统计", NSStringFromClass([self class]),
                                                           nil]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"PushFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults]
                         setBool:YES
                          forKey:@"PushFirstLaunch"];
        [FMUserTrack ctrlClicked:@"正式安装用户首次启动"
                          onPage:self];
    }
    [FMUserTrack ctrlClicked:@"正式安装用户启动"
                      onPage:self];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    FMLOG(@"Error in registration. Error: %@", err);
    [FMPushService registerDeviceToken:nil];
    [UT bindPageName:
                [NSDictionary dictionaryWithObjectsAndKeys:@"启动用户统计", NSStringFromClass([self class]),
                                                           nil]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"PushFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults]
                         setBool:YES
                          forKey:@"PushFirstLaunch"];
        [FMUserTrack ctrlClicked:@"越狱用户首次启动"
                          onPage:self];
    }
    [FMUserTrack ctrlClicked:@"越狱用户启动"
                      onPage:self];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [TBSDKPushCenterUserTrackEngine userTrackForReceivePushWithAPS:userInfo];
    FMLOG(@"RemoteNotification:[%@]", userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[FMMessageTimer instance] fire];
        return;
    }
    NSString *key = nil;
    if (userInfo) {
        key = [userInfo objectForKey:@"key"];
        [FMNotificationCommand fromPush:key];
    }
}

@end