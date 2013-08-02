//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "TBMBDefaultRootViewController.h"

@class FMSidePanelNavView;

@interface FMSidePanelRightViewController : TBMBDefaultRootViewController

@property (nonatomic, weak) FMSidePanelNavView *sidePanelNavView;

- (id)initWithTap:(NSArray *)tapData;
@end