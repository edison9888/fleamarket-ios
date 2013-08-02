//
// Created by yuanxiao on 13-7-3.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMSidePanelController.h"
#import "FMBaseListViewController.h"
#import "FMItemDO.h"
#import "FMItemDetailViewController.h"
#import "FMSubscribeService.h"
#import "FMApplication.h"
#import "FMLoginViewController.h"
#import "FMUser.h"
#import "FMUserTrack.h"


@implementation FMBaseListViewController {
    __weak FMListView *_listView;

    FMItemDOList *_listDO;
    FMListType _listType;
}

@synthesize listView = _listView;
@synthesize listDO = _listDO;
@synthesize listType = _listType;


- (id)init {
    self = [super init];
    if (self) {
        _listDO = [[FMItemDOList alloc] init];
    }

    return self;
}

- (void)initNavigationBar {
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
}

- (void)loadView {
    [super loadView];
    if (_listType != FMListTypeSell) {
        [self initNavigationBar];
    }

    CGRect tableRect = {{0, 0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20}};
    FMListView *listView = [[FMListView alloc] initWithFrame:tableRect
                                                    listType:_listType];
    __weak FMBaseListViewController *weakSelf = self;
    [listView setRequestItemsBlock:^(FMListView *listView1, BOOL isRequestMore) {
        [weakSelf requestItem:isRequestMore];
    }];
    listView.listDO = _listDO;
    [self.view addSubview:listView];
    _listView = listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.listDO.items.count == 0) {
        [self showPageLoadingView];
        [self requestItem:NO];
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)requestItem:(BOOL)isRequestMore {

}

- (void)requestItemFinish:(FMItemDOList *)itemDOList
            isRequestMore:(BOOL)isRequestMore
                isSuccess:(BOOL)isSuccess
                 errorMsg:(NSString *)errorMsg {
    if (isSuccess) {
        if (isRequestMore) {
            [_listDO.items addObjectsFromArray:itemDOList.items];
        } else {
            _listDO.items = [[NSMutableArray alloc] initWithArray:itemDOList.items];
        }
        _listDO.nextPage = itemDOList.nextPage;
        _listDO.totalCount = itemDOList.totalCount;

        [self removePageLoadingView];
        [_listView refreshTableView:isRequestMore];
    } else {
        if (_listType == FMListTypeCollect) {
            [self requestItemFinish:itemDOList
                      isRequestMore:isRequestMore
                          isSuccess:YES
                           errorMsg:errorMsg];
            return;
        }
        [_listView requestFinish:isRequestMore];
        if (!isRequestMore) {
            __weak FMBaseListViewController *weakSelf = self;
            [self showRefreshPage:^{
                [weakSelf requestItem:NO];
            }];
        }
        FMLog(@"request list data:%@", errorMsg);
    }
}

- (void)$$pushDetailViewController:(id <TBMBNotification>)notification itemDO:(FMItemDO *)itemDO {
    if (!self.showing) {
        return;
    }
    FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc] initWithItemDO:itemDO];
    detailViewController.isFromTheme = self.isFromTheme;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)$$pushDetailViewControllerWithClickComment:(id <TBMBNotification>)notification itemDO:(FMItemDO *)itemDO {
    if (!self.showing) {
        return;
    }
    FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc] initWithItemDO:itemDO];
    detailViewController.isScrollToComment = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)$$collectItem:(id <TBMBNotification>)notification itemDO:(FMItemDO *)itemDO {
    if (!self.showing) {
        return;
    }
    if (![[FMApplication instance].loginUser isLogin]) {
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess) {
                [self requestCollect:itemDO];
            }
        };
        UINavigationController *loginNavigationController = [[UINavigationController alloc]
                initWithRootViewController:loginViewController];
        [self.fmSidePanelController presentViewController:loginNavigationController
                                                 animated:YES
                                               completion:nil];
    } else {
        [self requestCollect:itemDO];
    }

}

- (void)requestCollect:(FMItemDO *)itemDO {
    if (itemDO.subscribed) {
        [FMSubscribeService unsubscribeItem:itemDO.id
                                     result:^(BOOL isSuccess) {
                                         if (isSuccess) {
                                             itemDO.subscribed = NO;
                                             NSString *num = [NSString stringWithFormat:@"%d", [itemDO.collectNum intValue] - 1];
                                             itemDO.collectNum = [num intValue] >= 0 ? num : @"0";
                                         }

                                         [self.listView refreshCollect:itemDO];
                                     }];
    } else {
        [FMSubscribeService subscribeItem:itemDO.id
                                   result:^(FMSubscribeType subscribeType, NSString *errorMsg) {
                                       if (subscribeType != FMSubscribeTypeFailed) {
                                           itemDO.subscribed = YES;
                                           [FMUserTrack ctrlClicked:@"FM_SUBSCRIBE_SUCCESS"];
                                       }
                                       if (subscribeType == FMSubscribeTypeSuccess) {
                                           itemDO.collectNum = [NSString stringWithFormat:@"%d", [itemDO.collectNum intValue] + 1];
                                       }
                                       [self.listView refreshCollect:itemDO];
                                   }];
    }
}

@end