//
// Created by yuanxiao on 13-6-7.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMRootViewController.h"


@class FMSidePanelNavItemView;

@interface FMSidePanelNavView : UIView

- (void)selectedTab:(FMTapType )pTapType;

- (void)setUnreadCount:(NSInteger)count;

- (id)initWithFrame:(CGRect)frame tapData:(NSArray *)tapData;

@end