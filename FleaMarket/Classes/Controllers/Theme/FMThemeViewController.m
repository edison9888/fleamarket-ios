// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import "FMThemeViewController.h"
#import "FMThemeItemCell.h"
#import "FMThemeDO.h"
#import "FMThemeService.h"
#import "FMListViewController.h"
#import "NSString+Helper.h"
#import "FMThemeView.h"
#import "FMUserTrack.h"


@implementation FMThemeViewController {
    UITableView *_tableView;
    FMThemeDOList *_themeDOList;

    __weak FMThemeView *_themeView;

}

- (id)init {
    self = [super init];
    if (self) {
        _themeDOList = [[FMThemeDOList alloc] init];
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"随便逛逛"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    __weak FMThemeViewController *weakSelf = self;
    CGRect rect = {{0, 0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kStatusBarHeight}};
    FMThemeView *themeView = [[FMThemeView alloc] initWithFrame:rect];
    themeView.themeDOList = _themeDOList;
    [themeView setRequestBlock:^(NSUInteger pageNum) {
        [weakSelf requestThemes:pageNum];
    }];
    [themeView touchThemeItemView:^(FMThemeDO *themeDO) {
        [weakSelf pushListViewController:themeDO];
    }];
    [self.view addSubview:themeView];
    _themeView = themeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestThemes:1];
    [self showPageLoadingView];
}

- (void)dealloc {
}

- (void)requestThemes:(NSUInteger)pageNum {
    id selfProxy = self.proxyObject;
    [[FMThemeService proxyObject]
            getThemes:pageNum
               result:^(BOOL isSuccess, FMThemeDOList *themeDOList, NSString *errMsg) {
                   [selfProxy receiveThemes:pageNum
                                  isSuccess:isSuccess
                                themeDOList:themeDOList
                                     errMsg:errMsg];
               }];
}

- (void)receiveThemes:(NSUInteger)pageNum
            isSuccess:(BOOL )isSuccess
          themeDOList:(FMThemeDOList *)themeDOList
               errMsg:(NSString *)errMsg {
    if (isSuccess) {
        if (pageNum > 1) {
            [_themeDOList.items addObjectsFromArray:themeDOList.items];
        } else {
            _themeDOList.items = [[NSMutableArray alloc] initWithArray:themeDOList.items];
        }
        _themeDOList.nextPage = themeDOList.nextPage;
        [_themeView refreshView:pageNum];
        [self removePageLoadingView];
    } else {
        [_themeView requestFinish:pageNum > 1];
        if (pageNum == 1 && _themeDOList.items.count == 0) {
            __weak FMThemeViewController *weakSelf = self;
            [self showRefreshPage:^{
                [weakSelf requestThemes:1];
            }];
        }
    }
}

- (void)pushListViewController:(FMThemeDO *)themeDO {
    [FMUserTrack ctrlClicked:[NSString stringWithFormat:@"%@_%@", themeDO.name, themeDO.id]
                      onPage:self];

    FMListViewController *listViewController = [[FMListViewController alloc] initWithTheme:themeDO.id];
    listViewController.isFromTheme = YES;
    if ([themeDO.picUrl isNotBlank]) {
        listViewController.titleUrl = themeDO.picUrl;
    }
    listViewController.hideSearchView = YES;
    if ([themeDO.name isNotBlank]) {
        [listViewController setTitle:themeDO.name];
    }

    listViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listViewController
                                         animated:YES];
    return;
}

@end