// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMSearchViewController.h"
#import "FMSearchBarView.h"
#import "FMListViewController.h"
#import "FMFrontCategoryViewController.h"
#import "FMHotKeywordView.h"
#import "FMStyle.h"
#import "FMTipsService.h"

@implementation FMSearchViewController {

}

- (void)initNavigationBar {
    [self setTitle:@"搜索"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *listTitleView = self.titleView;
    CGRect listTitleRect = {{0, 0}, {FM_SCREEN_WIDTH, kNavigationBarHeight * 2}};
    listTitleView.frame = listTitleRect;

    CGRect searchRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, kNavigationBarHeight}};
    FMSearchBarView *searchView = [[FMSearchBarView alloc] initWithFrame:searchRect
                                                           searchBarType:FMSearchBarTypeSearch];
    [listTitleView insertSubview:searchView atIndex:0];

    __weak FMSearchViewController *weakSelf = self;
    [searchView setSearchBlock:^(NSString *keyword) {
        [weakSelf pushListViewController:keyword];
    }];
}

- (void)initCategory:(UIView *)view pointY:(CGFloat)pointY {
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, FM_SCREEN_WIDTH, 1)];
    topLine.backgroundColor = FMColorWithRed(220, 220, 220);
    [view addSubview:topLine];

    UIButton *categoryButton = [[UIButton alloc]
            initWithFrame:CGRectMake(0, pointY + 1, FM_SCREEN_WIDTH, 44)];
    [categoryButton setTitle:@"所有类目" forState:UIControlStateNormal];
    [categoryButton setImage:[UIImage imageWithFileName:@"arrow_icon@2x.png"] forState:UIControlStateNormal];
    [categoryButton setBackgroundImage:[UIImage createImageWithColor:FMColorWithRGB0X(0xe9e9e9)]
                              forState:UIControlStateHighlighted];
    categoryButton.titleLabel.font = [FMFontSize instance].cellLabelSize;
    [categoryButton setTitleColor:[FMColor instance].cellColor forState:UIControlStateNormal];
    categoryButton.imageEdgeInsets = UIEdgeInsetsMake(0, FM_SCREEN_WIDTH - 20, 0, 0);
    categoryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [categoryButton addTarget:self action:@selector(touchCategory:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:categoryButton];

    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, pointY + 1 + 44, FM_SCREEN_WIDTH, 1)];
    bottomLine.backgroundColor = FMColorWithRed(220, 220, 220);
    [view addSubview:bottomLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self searchHotKeyword];
    [self showPageLoadingView];
}

- (void)searchHotKeyword {
    [FMTipsService getHotKeyword:^(NSArray *array) {
        __weak FMSearchViewController *weakSelf = self;
        if (!array) {
            [self showRefreshPage:^{
                [weakSelf searchHotKeyword];
            }];
            return;
        }
        [self removePageLoadingView];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:
                CGRectMake(0, self.titleView.frame.size.height, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - self.titleView.frame.size.height - 20 - kNavigationBarHeight)];
        scrollView.scrollsToTop = NO;
        [self.view addSubview:scrollView];

        FMHotKeywordView *hotKeywordView = [[FMHotKeywordView alloc]
                initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, 135)];
        [hotKeywordView setHotKeyword:array];
        [hotKeywordView setTouchKeyword:^(NSString *keyword) {
            [weakSelf pushListViewController:keyword];
        }];
        [scrollView addSubview:hotKeywordView];
        CGFloat height = (hotKeywordView.frame.origin.y + hotKeywordView.frame.size.height);

        [self initCategory:scrollView pointY:height];
        scrollView.contentSize = CGSizeMake(FM_SCREEN_WIDTH, height + 80);

        [self.view bringSubviewToFront:self.titleView];
    }];
}

- (void)touchCategory:(id)sender {
    FMFrontCategoryViewController *frontCategoryViewController = [[FMFrontCategoryViewController alloc]
            initWithType:FMFrontCategoryViewTypeSearch];
    [self.navigationController pushViewController:frontCategoryViewController animated:YES];
}

- (void)pushListViewController:(NSString *)keyword {
    FMListViewController *listViewController = [[FMListViewController alloc] initWithKeyword:keyword];
    [listViewController setTitle:@"搜索"];
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)$$receiveScrollTitle:(id <TBMBNotification>)notification offset:(NSNumber *)offset {
    if (self.showing) {
        [self $$receiveScroll:notification offset:offset];
    }
}

@end