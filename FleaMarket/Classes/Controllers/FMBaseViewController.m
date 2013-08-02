//
//  FMBaseViewController.m
//  FleaMarket
//
//  Created by Henson on 5/28/13.
//  Copyright (c) 2013 taobao.com. All rights reserved.
//


#import "FMBaseViewController.h"
#import "FMBasePageView.h"
#import "FMApplication.h"
#import "FMPageLoadingView.h"
#import "FMLoginViewController.h"
#import "FMUser.h"
#import "FMSidePanelController.h"
#import "FMStyle.h"
#import "FMCommon.h"
#import "FMListViewController.h"
#import "FMItemDO.h"

#define PAGE_VIEW_TAG (NSIntegerMax - 1)

@interface FMBaseViewController () <FMBaseBarViewDelegate>

@end

@implementation FMBaseViewController {
@private
    FMBaseBarViewDO *_barViewDO;
    __weak FMBaseBarView *_titleView;

    __weak FMPageLoadingView *_pageLoadingView;
    BOOL _showing;
}

@synthesize barViewDO = _barViewDO;

@synthesize showing = _showing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.barViewDO = [[FMBaseBarViewDO alloc] init];
    }
    return self;
}


- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect rect = CGRectMake(0, 0, FM_SCREEN_WIDTH, kNavigationBarHeight + kNavigationBarShadeHeight);
    FMBaseBarView *titleView = [[FMBaseBarView alloc]
                                               initWithFrame:rect
                                                  withViewDO:self.barViewDO];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.delegate = self;
    [self.view addSubview:titleView];
    _titleView = titleView;
}


- (UIButton *)leftBarButton {
    return _titleView.leftBarButton;
}

- (UIButton *)rightBarButton {
    return _titleView.rightBarButton;
}

- (FMBasePageView *)page {
    return (FMBasePageView *) [self.view viewWithTag:PAGE_VIEW_TAG];
}

- (void)setPage:(FMBasePageView *)page {
    page.tag = PAGE_VIEW_TAG;
    [self.view addSubview:page];
}

- (void)setRightButtonTitle:(NSString *)title {
    [self setRightButtonTitle:title
              rightButtonType:RightButtonWithNoIcon
                    iconImage:nil];
}

- (void)setRightButtonTitle:(NSString *)title
            rightButtonType:(FMHeaderBarRightButtonType)rightButtonType {
    [self setRightButtonTitle:title
              rightButtonType:rightButtonType
                    iconImage:nil];
}

- (void)setRightButtonIconImage:(UIImage *)iconImage {
    if (!iconImage) {
        return;
    }
    [self setRightButtonTitle:nil
              rightButtonType:RightButtonWithIcon
                    iconImage:iconImage];
}

- (void)setRightButtonSelectIconImage:(UIImage *)iconImage {
    self.barViewDO.rightButtonShow = YES;
    self.barViewDO.rightSelectIcon = iconImage;
}

- (void)setRightButtonTitle:(NSString *)title
            rightButtonType:(FMHeaderBarRightButtonType)rightButtonType
                  iconImage:(UIImage *)iconImage {
    self.barViewDO.rightButtonType = rightButtonType;
    self.barViewDO.rightButtonShow = YES;
    self.barViewDO.rightIcon = iconImage;
    self.barViewDO.rightButtonName = title;
}

- (void)setLeftBarButtonTitle:(NSString *)title
                   buttonType:(FMHeaderBarLeftButtonType)buttonType
                    iconImage:(UIImage *)iconImage {
    self.barViewDO.leftButtonShow = YES;
    self.barViewDO.leftIcon = iconImage;
    self.barViewDO.leftButtonName = title;
    self.barViewDO.leftButtonType = buttonType;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FMApplication instance].currentViewController = self;

    if ([self conformsToProtocol:@protocol(FMNeedClosePanWithSidePanel)]) {
        self.fmSidePanelController.recognizesPanGesture = NO;
    } else {
        self.fmSidePanelController.recognizesPanGesture = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.showing = NO;
    [FMApplication instance].currentViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.showing = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:_titleView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self releaseViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)releaseViews {

}

- (void)setTitle:(NSString *)title {
    self.barViewDO.title = title;
}

- (void)setTitleBg:(FMHeaderBarBGType)headerBarBGType {
    self.barViewDO.headerBarBGType = headerBarBGType;
}

- (void)onRightButtonPressed:(UIButton *)button {
    [self rightAction:button];
}

- (void)onLeftButtonPressed:(UIButton *)button {
    [self leftAction:button];
}


- (void)leftAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightAction:(id)sender {
    return;
}

#pragma mark -- loading
- (void)showPageLoadingView {
    if (_pageLoadingView) {
        return;
    }
    CGRect pageLoadingViewRect = {{0, kNavigationBarHeight + 1},
            {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight - 1}};
    FMPageLoadingView *pageLoadingView = [[FMPageLoadingView alloc] initWithFrame:pageLoadingViewRect];
    pageLoadingView.backgroundColor = [[FMColor instance] viewControllerBgColor];
    [self.view addSubview:pageLoadingView];
    [self.view bringSubviewToFront:pageLoadingView];
    _pageLoadingView = pageLoadingView;
}

- (void)removePageLoadingView {
    if (_pageLoadingView) {
        [_pageLoadingView removeFromSuperview];
    }
}

- (void)showPageLoadingText:(NSString *)text {
    [_pageLoadingView showMessageText:text];
}

- (void)showRefreshPage:(void (^)(void))refreshBlock {
    [_pageLoadingView showRefreshText:refreshBlock];
}

#pragma mark -- login
- (void)pushViewControllerWithLogin:(UIViewController *)viewController animated:(BOOL)animated {
    [self pushViewControllerWithLogin:viewController
                             animated:animated
           withUINavigationController:nil];
}

- (void)pushViewControllerWithLogin:(UIViewController *)viewController
                           animated:(BOOL)animated
         withUINavigationController:(UINavigationController *)navigationController {
    UINavigationController *nav = navigationController ? : self.navigationController;
    if ([viewController conformsToProtocol:@protocol(FMNeedLoginProtocol)] &&
            ![[FMApplication instance].loginUser isLogin]) {
        [self dismissModalViewControllerAnimated:NO];
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess && nav.topViewController != viewController) {
                [nav pushViewController:viewController animated:animated];
            }
        };
        UINavigationController *loginNavigationController = [[UINavigationController alloc]
                initWithRootViewController:loginViewController];
        [self.fmSidePanelController presentViewController:loginNavigationController
                                                 animated:YES
                                               completion:nil];
        return;

    } else {
        [nav pushViewController:viewController animated:animated];
    }
}

#pragma mark -- notify
- (void)$$pushUserItemsControllerByItemDetail:(id <TBMBNotification>)notification
                                       itemDO:(FMItemDO *)itemDO {
    if (!self.showing) {
        return;
    }

    [FMCommon hideKeyboard];

    FMListViewController *listViewController = [[FMListViewController alloc] init];
    listViewController.title = [NSString stringWithFormat:@"%@的宝贝", itemDO.userNick];
    listViewController.hideSearchView = YES;
    listViewController.itemDO = itemDO;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)$$receiveScroll:(id <TBMBNotification>)notification offset:(NSNumber *)offset {
    if (!self.showing) {
        return;
    }

    CGFloat y = -[offset floatValue];
    CGRect rect = _titleView.frame;
    rect.origin.y += y;
    if (rect.origin.y > 0) {
        rect.origin.y = 0;
    } else if (rect.origin.y < -rect.size.height) {
        rect.origin.y = -rect.size.height;
    }
    if (abs((int) y) > 3) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _titleView.frame = rect;
                         }];
    } else {
        _titleView.frame = rect;
    }
}

@end
