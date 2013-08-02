//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMSidePanelBaseViewController.h"
#import "FMListView.h"
#import "FMBaseListViewController.h"

@class FMSearchParameter;
@class FMItemDO;

#define kListPageNum  20

@interface FMListViewController : FMBaseListViewController

@property(nonatomic, strong) NSString *titleUrl;
@property(nonatomic, assign) BOOL hideSearchView;
@property(nonatomic, strong) FMItemDO *itemDO;         //搜卖家

- (id)initWithKeyword:(NSString *)keyword;

- (id)initWithTheme:(NSString *)themeId;

- (id)initWithCategory:(NSArray *)array;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end