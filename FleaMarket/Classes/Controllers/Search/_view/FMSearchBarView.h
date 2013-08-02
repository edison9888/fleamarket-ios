//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"

typedef enum {
    FMSearchBarTypeSearch,
    FMSearchBarTypeSearchResult,
    FMSearchBarTypeResell
} FMSearchBarType;

@interface FMSearchBarView : UIView <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *keyword;

- (id)initWithFrame:(CGRect)frame searchBarType:(FMSearchBarType)barType;

- (void)setSearchBlock:(void (^)(NSString *keyword))block;

- (void)setFilterBlock:(void (^)())block;

@end