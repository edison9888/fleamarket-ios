// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "FMHomeViewController.h"
#import "FMHomeView.h"
#import "TBMBDefaultRootViewController+TBMBProxy.h"
#import "FMStyle.h"
#import "FMListViewController.h"
#import "FMHomeService.h"
#import "FMHomeItemDO.h"
#import "FMItemDO.h"
#import "FMItemDetailViewController.h"
#import "FMWebviewController.h"
#import "FMUserTrack.h"

#define kHomeViewTimer   5


@implementation FMHomeViewController {
@private
    NSMutableArray *_items;
    FMHomeViewDO *_viewDO;
    NSTimer *_timer;

    __weak UIView *_guideBgView;
}

- (id)init {
    self = [super init];
    if (self) {
        _viewDO = [[FMHomeViewDO alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:kHomeViewTimer
                                                  target:self
                                                selector:@selector(reUpdateTimer)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];
    }

    return self;
}

- (void)reUpdateTimer {
    if (!self.showing) {
        return;
    }
    TBMBGlobalSendNotificationForSEL(@selector($$homeScrollImageView:));
}

- (void)initNavigationBar {
    [self setTitle:@"淘宝二手"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];
    self.view.backgroundColor = [FMColor instance].viewControllerBgColor;

    CGRect tableRect = {{0, 0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20}};
    FMHomeView *homeView = [[FMHomeView alloc]
                                        initWithFrame:tableRect
                                           withViewDO:_viewDO];
    homeView.delegate = self.proxyObject;
    [self.view addSubview:homeView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_viewDO.items.count == 0) {
        [self refreshData];
        [self showPageLoadingView];
    }
    [self showGuide];
}

- (void)showGuide {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_HOME]) {
        __weak FMHomeViewController *weakSelf = self;
        UIView *guideBgView = [[UIView alloc] initWithFrame:
                CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        guideBgView.backgroundColor = [UIColor blackColor];
        guideBgView.userInteractionEnabled = YES;
        guideBgView.alpha = 0.8;
        guideBgView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [weakSelf dismissGuide];
        };
        _guideBgView = guideBgView;
        [self.view addSubview:guideBgView];

        UIImage *guideImage = [UIImage imageWithFileName:@"guide_home@2x.png"];
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake((guideBgView.frame.size.width - guideImage.size.width) / 2, (guideBgView.frame.size.height - guideImage.size.height) / 2,
                        guideImage.size.width, guideImage.size.height)];
        guideImageView.image = guideImage;
        [guideBgView addSubview:guideImageView];
    }
}

- (void)dismissGuide {
    [_guideBgView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FM_GUIDE_HOME];
}

- (void)dealloc {

}

- (void)clickOnHomeItem:(FMHomeItemDO *)homeItemDO {
    FMHomeActionDO *actionDO = homeItemDO.action;
    if (actionDO.itemId) {
        FMItemDO *itemDO = [[FMItemDO alloc] init];
        itemDO.id = actionDO.itemId;
        FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc]
                                                                                        initWithItemDO:itemDO];
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController
                                             animated:YES];
        return;

    }

    if (actionDO.search) {
        FMListViewController *listViewController = [[FMListViewController alloc]
                                                                          initWithDictionary:actionDO.search];
        listViewController.hideSearchView = YES;

        if (actionDO.withUserNick) {
            FMItemDO *itemDO = [[FMItemDO alloc] init];
            itemDO.userNick = actionDO.withUserNick;
            itemDO.userId = homeItemDO.seller.sellerHeadUrl;
            listViewController.itemDO = itemDO;
        } else if (actionDO.withPicUrl) {
            listViewController.titleUrl = actionDO.withPicUrl;
        }
        if (actionDO.withTitle) {
            [listViewController setTitle:actionDO.withTitle];
        }
        [self.navigationController pushViewController:listViewController
                                             animated:YES];
        return;
    }

    if (actionDO.webUrl) {
        FMWebViewController *webView = [[FMWebViewController alloc] init];
        webView.url = actionDO.webUrl;
        webView.webViewType = FMWebViewTypeRequest;
        webView.title = actionDO.withTitle;
        [self.navigationController pushViewController:webView
                                             animated:YES];
        return;
    }


}

- (void)requestMore {
    [[FMHomeService proxyObject]
                    getHomeData:++_viewDO.pageNo
                         result:^(BOOL isSuccess, FMHomeRowList *data, NSString *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (isSuccess) {
                                     _viewDO.more = YES;
                                     [_viewDO.items addObjectsFromArray:data.items];
                                     _viewDO.items = _viewDO.items;
                                 } else {
                                     _viewDO.errorMsg = error;
                                 }
                             }
                             );
                         }];
}

- (void)refreshData {
    _viewDO.pageNo = 1;
    [[FMHomeService proxyObject]
                    getHomeData:_viewDO.pageNo
                         result:^(BOOL isSuccess, FMHomeRowList *data, NSString *error) {
                             if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_HOME]) {
                                if (isSuccess) {
                                    _items = [[NSMutableArray alloc] initWithArray:data.items];
                                    return;
                                }
                             }
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (isSuccess) {
                                     if (_viewDO.items.count > 0) {
                                         [FMUserTrack ctrlClicked:@"FM_HOME_REFRESH"];
                                     }
                                     _viewDO.more = NO;
                                     _viewDO.items = [[NSMutableArray alloc] initWithArray:data.items];
                                     [self removePageLoadingView];
                                 } else {
                                     _viewDO.errorMsg = error;
                                     __weak FMHomeViewController *weakSelf = self;
                                     [self showRefreshPage:^{
                                         [weakSelf refreshData];
                                     }];
                                 }
                             }
                             );
                         }];
}

- (void)$$guideFinish {
    _viewDO.more = NO;
    _viewDO.items = [[NSMutableArray alloc] initWithArray:_items];
    _items = nil;
    [self removePageLoadingView];
}

@end