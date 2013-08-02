//
// Created by yuanxiao on 13-7-12.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FMAccountInfo;
@class FMItemDO;
@class FMItemDOList;


@interface FMSellerTitleView : UIView

@property (nonatomic, strong) FMItemDOList *listDO;         //数据源
@property (nonatomic, strong) FMAccountInfo *accountInfo;   //在售
@property (nonatomic, strong) FMItemDO *itemDO;             //搜人的宝贝
@property (nonatomic, strong) NSArray *flagArray;

- (id)initWithFrame:(CGRect)frame withItemDO:(FMItemDO *)itemDO;

- (void)setSellerVip:(id)data;

@end