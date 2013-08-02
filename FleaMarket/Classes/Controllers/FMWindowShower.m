//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-7-21 上午10:26.
//


#import <TaobaoRemoteObject/RemoteContext.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMWindowShower.h"
#import "FMCustomStatusBar.h"
#import "FMItemDetailViewController.h"
#import "FMItemDO.h"
#import "FMApplication.h"
#import "FMListViewController.h"
#import "FMMessageViewController.h"
#import "FMLoginViewController.h"
#import "FMMessageTimer.h"
#import "TBMBDefaultMediator.h"
#import "TBMBDefaultMediator+TBMBProxy.h"
#import "FMSidePanelController.h"


@implementation FMWindowShower {
@private
    TBMBDefaultMediator *_mediator;
}

+ (FMWindowShower *)instance {
    static FMWindowShower *_instance = nil;
    static dispatch_once_t _oncePredicate_FMWindowShower;

    dispatch_once(&_oncePredicate_FMWindowShower, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _mediator = [TBMBDefaultMediator mediatorWithRealReceiver:self];
    }
    return self;
}


- (void)$$hasNewMessage:(id <TBMBNotification>)notification isSync:(NSNumber *)isSync {
    [FMCustomStatusBar showStatusMessage:[isSync boolValue] ? @"同步完成" : @"您有新消息"
                               hideAfter:2];
}

- (void)gotoDetailWithId:(NSString *)itemId {
    UIViewController *viewController = [FMApplication instance].currentViewController;
    if (viewController) {
        if ([viewController isMemberOfClass:[FMItemDetailViewController class]]
                && [((FMItemDetailViewController *) viewController).itemDO.id isEqualToString:itemId]) {

            return;
        }
        FMItemDetailViewController *itemDetailViewController = [[FMItemDetailViewController alloc]
                                                                                            initWithItemId:itemId];
        [viewController.navigationController pushViewController:itemDetailViewController
                                                       animated:YES];
    }
}


- (void)gotoSearch:(NSDictionary *)parameter {
    UIViewController *viewController = [FMApplication instance].currentViewController;
    if (viewController) {
        FMListViewController *listViewController = [[FMListViewController alloc]
                                                                          initWithDictionary:parameter];
        listViewController.hideSearchView = YES;

        [viewController.navigationController pushViewController:listViewController
                                                       animated:YES];
    }
}

- (void)goToMessageView:(BOOL)loginDone withKey:(NSString *)key {
    UIViewController *viewController = [FMApplication instance].currentViewController;
    if (loginDone) {
        [self goToMessageViewController:viewController
                                withKey:key];
        [[FMMessageTimer instance] fire];
    } else {
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess) {
                [self goToMessageViewController:viewController withKey:key];
                [[FMMessageTimer instance] fire];
            }
        };
        [viewController presentViewController:loginViewController
                                     animated:YES
                                   completion:nil];
    }
}


- (void)goToMessageViewController:(UIViewController *)viewController withKey:(NSString *)key {
    TBMBGlobalSendNotificationForSEL(@selector($$clearMessageUnreadCount:));
    NSArray *array = [key componentsSeparatedByString:@"_"];
    FMMessageViewType messageViewType;
    if (array.count > 0 && [[array objectAtIndex:0] integerValue] == 1) {
        messageViewType = FMMessageViewTypeReceive;
    } else {
        messageViewType = FMMessageViewTypeSystem;
    }
    if ([viewController isMemberOfClass:[FMMessageViewController class]]) {
        FMMessageViewController *messageViewController = (FMMessageViewController *)viewController;
        messageViewController.selectMessageType = messageViewType;
        return;
    }

    if (viewController.navigationController) {
        for (UIViewController *v in viewController.navigationController.childViewControllers) {
            if ([v isMemberOfClass:[FMMessageViewController class]]) {
                FMMessageViewController *messageViewController = (FMMessageViewController *)v;
                messageViewController.selectMessageType = messageViewType;
                [viewController.navigationController popToViewController:messageViewController
                                                                animated:YES];
                return;
            }
        }
    }
    FMMessageViewController *messageViewController = [[FMMessageViewController alloc] init];
    messageViewController.selectMessageType = messageViewType;
    [viewController.navigationController pushViewController:messageViewController
                                                   animated:YES];
}


- (void)dealloc {
    [_mediator close];
}

- (void)retryLoginAndRequest:(RemoteContext *)context {
    UIViewController *controller = [FMApplication instance].currentViewController.fmSidePanelController;
    UIAlertView *alert = [UIAlertView alertViewWithTitle:@"温馨提示"
                                                 message:@"亲,会话失效了!您可以尝试重新登陆."];
    [alert setCancelButtonWithTitle:@"取消"
                            handler:nil];
    [alert addButtonWithTitle:@"重新登陆"
                      handler:^{
                          FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
                          loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
                              if (isLoginSuccess) {
                                  [context request];
                              }
                          };
                          if (controller) {
                              [controller presentViewController:[[UINavigationController alloc]
                                                                                         initWithRootViewController:loginViewController]
                                                       animated:YES
                                                     completion:nil];
                          }

                      }];
    [alert show];
}

- (id)proxyObject {
    return _mediator.proxyObject;
}
@end