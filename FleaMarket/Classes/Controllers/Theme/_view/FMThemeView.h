//
// Created by yuanxiao on 13-7-19.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"

@class FMThemeDOList;
@class FMThemeDO;


@interface FMThemeView : FMBaseScrollView

@property (nonatomic, strong) FMThemeDOList *themeDOList;

- (void)setRequestBlock:(void(^)(NSUInteger pageNum))block;

- (void)touchThemeItemView:(void(^)(FMThemeDO *themeDO))block;

- (void)refreshView:(NSUInteger)pageNum;

@end