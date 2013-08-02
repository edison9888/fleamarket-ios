//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMSidePanelController.h"
#import "FMSidePanelBaseViewController.h"


@implementation FMSidePanelBaseViewController {

}

- (void)loadView {
    [super loadView];
    [self setRightButtonIconImage:[UIImage imageWithFileName:@"header_right_icon.png"]];
    [self setRightButtonSelectIconImage:[UIImage imageWithFileName:@"header_right_icon_highlight.png"]];
}

- (void)rightAction:(id)sender {
    [super rightAction:sender];
    [self.fmSidePanelController toggleRightPanel:sender];
}

@end