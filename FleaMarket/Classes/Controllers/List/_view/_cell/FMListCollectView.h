//
// Created by yuanxiao on 13-7-12.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMListView.h"

@class FMItemDO;


@interface FMListCollectView : UIButton

- (void)setItemDO:(FMItemDO *)itemDO listType:(FMListType)listType;

- (void)setClickBlock:(void(^)())block;

@end