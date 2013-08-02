//
// Created by yuanxiao on 13-7-11.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FMItemDO;

typedef enum {
    FMItemTitleViewTypeList,
    FMItemTitleViewTypeDetail
} FMItemTitleViewType;

@interface FMItemTitleView : UIView

- (CGFloat)setItemDO:(FMItemDO *)itemDO withType:(FMItemTitleViewType)type;

+ (CGFloat)getHeight:(FMItemDO *)itemDO;

@end