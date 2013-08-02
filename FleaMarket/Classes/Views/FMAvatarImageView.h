// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMImageView.h"

@class FMItemDO;

@interface FMAvatarImageView : FMImageView

@property (nonatomic, assign) BOOL isClick;

@property (nonatomic, strong) FMItemDO *itemDO;

@end