// 
// Created by henson on 6/18/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMAnimationTableViewCell.h"

@class FMThemeDO;

@interface FMThemeItemCell : FMAnimationTableViewCell

+ (float)cellHeight:(FMThemeDO *)themeDO;

- (void)setThemeDO:(FMThemeDO *)themeDO serverTime:(NSString *)serverTime;

@end