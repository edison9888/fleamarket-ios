//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <JASidePanels/JASidePanelController.h>

@class FMSidePanelController;

@interface UIViewController (FMSidePanel)

// The nearest ancestor in the view controller hierarchy that is a side panel controller.
@property (nonatomic, weak, readonly) FMSidePanelController *fmSidePanelController;

@end

@interface FMSidePanelController : JASidePanelController

@end