//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"

#define kListItemCellBaseHeight   310
#define kListItemCellMoreCommentHeight   35

typedef enum {
    FMListTypeTheme = 0,
    FMListTypeSearchSeller,
    FMListTypeSearch,
    FMListTypeSell,
    FMListTypeCollect,
} FMListType;

@class FMItemDOList;
@class FMItemDO;
@class FMAccountInfo;


@interface FMListView : FMBaseScrollView

@property (nonatomic, copy) NSString *titleUrl;             //主题
@property (nonatomic, strong) FMItemDOList *listDO;         //数据源
@property (nonatomic, strong) FMAccountInfo *accountInfo;   //在售

- (id)initWithFrame:(CGRect)frame listType:(FMListType)listType;

- (void)setRequestItemsBlock:(void (^)(FMListView *listView, BOOL isRequestMore))block;
- (void)setRequestCommentBlock:(void (^)(NSString *id, NSUInteger row))block;

- (void)refreshRow:(NSUInteger)row;

- (void)refreshCollect:(FMItemDO *)itemDO;

- (void)refreshTableView:(BOOL)isRequestMore;

//搜卖家
- (void)setSearchSellerWithItemDO:(FMItemDO *)itemDO;
- (void)setSellerFlags:(NSArray *)array;
- (void)setSellerVip:(id)data;

@end