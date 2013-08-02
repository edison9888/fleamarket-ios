// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBDefaultReceiverImpl.h>
#import <MBMvc/TBMBBind.h>
#import "FMRootViewController.h"
#import "FMHomeViewController.h"
#import "FMThemeViewController.h"
#import "FMSearchViewController.h"
#import "FMAccountViewController.h"
#import "FMSettingViewController.h"
#import "FMSidePanelRightViewController.h"
#import "FMPostViewController.h"
#import "FMNavigationViewController.h"
#import "FMLoginViewController.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMSidePanelNavView.h"
#import "FMMenuView.h"
#import "FMSidePanelNavItemView.h"

@implementation FMRootViewControllerDO {
@private
    NSString *_itemName;
    NSString *_itemImage;
    UIViewController *_viewController;
    NSString *_itemSelectedImage;
    UIColor *_itemBGColor;
    UIColor *_itemNameSelectedColor;
}

@synthesize itemName = _itemName;
@synthesize itemImage = _itemImage;
@synthesize viewController = _viewController;

@synthesize itemSelectedImage = _itemSelectedImage;
@synthesize itemBGColor = _itemBGColor;
@synthesize itemNameSelectedColor = _itemNameSelectedColor;
@end

@interface FMRootViewController () <TBMBMessageReceiver>

@end

@implementation FMRootViewController {
@private
    NSArray *_tapData;
    FMMenuView *_menuView;
    UIPinchGestureRecognizer *_pinchGestureRecognizer;

    TBMBDefaultReceiverImpl

- (id)init {
    self = [super init];
    if (self) {
        [[TBMBGlobalFacade instance] subscribeNotification:self];
        TBMBAutoBindingKeyPath(self);
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.shouldDelegateAutorotateToVisiblePanel = NO;
    self.rightFixedWidth = FM_SCREEN_WIDTH - kSidePanelRightFixedWidth;
    self.maximumAnimationDuration = 0.25;
    self.panningLimitedToTopViewController = NO;

    _tapData = [self tabData];
    self.centerPanel = ((FMRootViewControllerDO *) [_tapData objectAtIndex:FMTapTypeHome]).viewController;
    FMSidePanelRightViewController *controller = [[FMSidePanelRightViewController alloc] initWithTap:_tapData];

    self.rightPanel = [[UINavigationController alloc] initWithRootViewController:controller];

    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(pinchAct:)];
    [self.view addGestureRecognizer:_pinchGestureRecognizer];
    _menuView = [[FMMenuView alloc]
            initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20)
                  tapData:_tapData];
}

TBMBWhenThisKeyPathChange(self, state) {
    if (isInit) {
        return;
    }
    JASidePanelState style = (JASidePanelState) [new intValue];
    if (style == JASidePanelCenterVisible) {
        _pinchGestureRecognizer.enabled = YES;
    } else {
        _pinchGestureRecognizer.enabled = NO;
    }
}

- (void)pinchAct:(UIPinchGestureRecognizer *)gesture {
    [_menuView pinchAnimationSuperView:self.view gesture:gesture];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_HOME]) {
        FMRootViewControllerDO *accountDO = [_tapData objectAtIndex:FMTapTypeHome];
        FMNavigationViewController *nav = (FMNavigationViewController *)accountDO.viewController;
        [((FMHomeViewController *) [nav.viewControllers objectAtIndex:0]) dismissGuide];
    }
}

- (NSArray *)tabData {
    FMHomeViewController *homeViewController = [[FMHomeViewController alloc] init];
    FMNavigationViewController *homeNavigationController = [[FMNavigationViewController alloc] initWithRootViewController:homeViewController];
    FMRootViewControllerDO *homeDO = [[FMRootViewControllerDO alloc] init];
    homeDO.tapType = FMTapTypeHome;
    homeDO.itemName = FMTapHomeName;
    homeDO.itemBGColor = FMColorWithRed(38, 160, 173);
    homeDO.itemNameSelectedColor = FMColorWithRed(28, 83, 120);
    homeDO.itemImage = @"icon_side_home.png";
    homeDO.itemSelectedImage = @"icon_side_home_selected.png";
    homeDO.viewController = homeNavigationController;

    FMThemeViewController *themeViewController = [[FMThemeViewController alloc] init];
    FMNavigationViewController *topicNavigationController = [[FMNavigationViewController alloc] initWithRootViewController:themeViewController];
    FMRootViewControllerDO *themeDO = [[FMRootViewControllerDO alloc] init];
    themeDO.tapType = FMTapTypeTheme;
    themeDO.itemName = FMTapThemeName;
    themeDO.itemBGColor = FMColorWithRed(236, 73, 60);
    themeDO.itemNameSelectedColor = FMColorWithRed(145, 46, 19);
    themeDO.itemImage = @"icon_side_market.png";
    themeDO.itemSelectedImage = @"icon_side_market_selected.png";
    themeDO.viewController = topicNavigationController;

    FMRootViewControllerDO *postDO = [[FMRootViewControllerDO alloc] init];
    postDO.tapType = FMTapTypePost;
    postDO.itemName = FMTapPostName;
    postDO.itemBGColor = FMColorWithRed(240, 172, 20);
    postDO.itemNameSelectedColor = FMColorWithRed(142, 72, 28);
    postDO.itemImage = @"icon_side_post.png";
    postDO.itemSelectedImage = @"icon_side_post_selected.png";

    FMAccountViewController *accountViewController = [[FMAccountViewController alloc] init];
    FMNavigationViewController *accountNavigationController = [[FMNavigationViewController alloc] initWithRootViewController:accountViewController];
    FMRootViewControllerDO *accountDO = [[FMRootViewControllerDO alloc] init];
    accountDO.tapType = FMTapTypeAccount;
    accountDO.itemName = FMTapAccountName;
    accountDO.itemBGColor = FMColorWithRed(131, 72, 223);
    accountDO.itemNameSelectedColor = FMColorWithRed(71, 16, 169);
    accountDO.itemImage = @"icon_side_user.png";
    accountDO.itemSelectedImage = @"icon_side_user_selected.png";
    accountDO.viewController = accountNavigationController;

    FMSearchViewController *searchViewController = [[FMSearchViewController alloc] init];
    FMNavigationViewController *searchNavigationController = [[FMNavigationViewController alloc] initWithRootViewController:searchViewController];
    FMRootViewControllerDO *searchDO = [[FMRootViewControllerDO alloc] init];
    searchDO.tapType = FMTapTypeSearch;
    searchDO.itemName = FMTapSearchName;
    searchDO.itemBGColor = FMColorWithRed(19, 92, 151);
    searchDO.itemNameSelectedColor = FMColorWithRed(21, 50, 111);
    searchDO.itemImage = @"icon_side_search.png";
    searchDO.itemSelectedImage = @"icon_side_search_selected.png";
    searchDO.viewController = searchNavigationController;

    FMSettingViewController *settingViewController = [[FMSettingViewController alloc] init];
    FMNavigationViewController *settingNavigationController = [[FMNavigationViewController alloc] initWithRootViewController:settingViewController];
    FMRootViewControllerDO *settingDO = [[FMRootViewControllerDO alloc] init];
    settingDO.tapType = FMTapTypeSetting;
    settingDO.itemName = FMTapSettingName;
    settingDO.itemBGColor = FMColorWithRed(66, 161, 113);
    settingDO.itemNameSelectedColor = FMColorWithRed(30, 94, 41);
    settingDO.itemImage = @"icon_side_setting.png";
    settingDO.itemSelectedImage = @"icon_side_setting_selected.png";
    settingDO.viewController = settingNavigationController;

    return [NSArray arrayWithObjects:homeDO, themeDO, postDO, accountDO, searchDO, settingDO, nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)$$postItemDidFinished:(id <TBMBNotification>)notification {
    FMRootViewControllerDO *accountDO = [_tapData objectAtIndex:FMTapTypeAccount];
    FMSidePanelNavView *sidePanelNavView = [self getSidePanelRight].sidePanelNavView;
    UIViewController *viewController = accountDO.viewController;

    FMNavigationViewController *nav = (FMNavigationViewController *) viewController;
    [nav popToRootViewControllerAnimated:NO];

    [self gotoAccount:accountDO.tapType
     sidePanelNavView:sidePanelNavView
       viewController:viewController];
    TBMBGlobalSendTBMBNotification([notification createNextNotificationForSEL:@selector($$postItemDidFinishedToAccount:withIsLoad:)
                                                                     withBody:nil]);
}

- (void)$$selectedTab:(id <TBMBNotification>)notification navItemView:(FMSidePanelNavItemView *)navItemView {
    FMSidePanelNavView *sidePanelNavView = [self getSidePanelRight].sidePanelNavView;
    UIViewController *viewController = navItemView.dataDO.viewController;
    if (navItemView.dataDO.tapType == FMTapTypePost) {
        [self gotoPost:navItemView.dataDO.tapType
      sidePanelNavView:sidePanelNavView];
    } else if (navItemView.dataDO.tapType == FMTapTypeAccount) {
        [self gotoAccount:navItemView.dataDO.tapType
         sidePanelNavView:sidePanelNavView
           viewController:viewController];
    } else {
        [self.fmSidePanelController setCenterPanel:viewController];
        [sidePanelNavView selectedTab:navItemView.dataDO.tapType];
        [_menuView selectedTab:navItemView.dataDO.tapType];
    }
    if (navItemView.dataDO.tapType == FMTapTypeHome
            && ![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_HOME]) {
        FMNavigationViewController *nav = (FMNavigationViewController *)viewController;
        [((FMHomeViewController *) [nav.viewControllers objectAtIndex:0]) dismissGuide];
    }
}

- (void)gotoPost:(FMTapType)pTapType sidePanelNavView:(FMSidePanelNavView *)sidePanelNavView {
    if (![[FMApplication instance].loginUser isLogin]) {
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess) {
                [self postViewController];
                [sidePanelNavView selectedTab:pTapType];
                [_menuView selectedTab:pTapType];
            }
        };
        [self presentModalLoginViewController:loginViewController];
    } else {
        [self postViewController];
        [sidePanelNavView selectedTab:pTapType];
        [_menuView selectedTab:pTapType];
    }
}

- (void)gotoAccount:(FMTapType)pTapType
   sidePanelNavView:(FMSidePanelNavView *)sidePanelNavView
     viewController:(UIViewController *)viewController {
    if (self.fmSidePanelController.centerPanel == viewController) {
        FMNavigationViewController *nav = (FMNavigationViewController *) viewController;
        [nav popToRootViewControllerAnimated:YES];
        [self.fmSidePanelController setCenterPanel:viewController];
        [sidePanelNavView selectedTab:pTapType];
        [_menuView selectedTab:pTapType];
    } else {
        if (![[FMApplication instance].loginUser isLogin]) {
            FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
            loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
                if (isLoginSuccess) {
                    [self.fmSidePanelController setCenterPanel:viewController];
                    [sidePanelNavView selectedTab:pTapType];
                    [_menuView selectedTab:pTapType];
                }
            };
            [self presentModalLoginViewController:loginViewController];
        } else {
            [self.fmSidePanelController setCenterPanel:viewController];
            [sidePanelNavView selectedTab:pTapType];
            [_menuView selectedTab:pTapType];
        }
    }
}

- (void)postViewController {
    FMPostViewController *postViewController = [[FMPostViewController alloc] init];
    UINavigationController *postNavigationController = [[UINavigationController alloc] initWithRootViewController:postViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.fmSidePanelController presentViewController:postNavigationController
                                             animated:YES
                                           completion:^{
                                               [self.fmSidePanelController showCenterPanelAnimated:YES];
                                           }];
}

- (void)presentModalLoginViewController:(UIViewController *)loginViewController {
    UINavigationController *loginNavigationController = [[UINavigationController alloc]
            initWithRootViewController:loginViewController];
    [self presentViewController:loginNavigationController
                                             animated:YES
                                           completion:nil];
}

- (FMSidePanelRightViewController *)getSidePanelRight {
    UINavigationController *nav = (UINavigationController *) self.rightPanel;
    return (FMSidePanelRightViewController *) [nav.viewControllers objectAtIndex:0];
}

//更新消息未读数
- (void)$$receiveMessageUnreadCount:(id <TBMBNotification>)notification count:(NSNumber *)count {
    [_menuView setUnreadCount:[count intValue]];
    [[self getSidePanelRight].sidePanelNavView setUnreadCount:[count intValue]];
}

//清除消息未读数
- (void)$$hasClearMessageUnreadCount:(id <TBMBNotification>)notification {
    [_menuView setUnreadCount:0];
    [[self getSidePanelRight].sidePanelNavView setUnreadCount:0];
}

//登录成功后刷新数据
- (void)$$loginSuccess:(id <TBMBNotification>)notification {
    TBMBGlobalSendNotificationForSEL(@selector($$getMessageUnreadCount:));
}

- (void)dealloc {
    [[TBMBGlobalFacade instance] unsubscribeNotification:self];
}

@end