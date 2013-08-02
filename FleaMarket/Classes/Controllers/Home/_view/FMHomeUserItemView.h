// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMHomeItemViewProtocol.h"

@class FMHomeItemDO;

@interface FMHomeUserItemView : UIView <FMHomeItemViewProtocol>
- (FMHomeItemDO *)homeItemDO;

- (void)setHomeItemDO:(FMHomeItemDO *)itemDO;

@end