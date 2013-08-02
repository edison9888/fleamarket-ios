//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBGlobalFacade.h>
#import "FMSidePanelRightViewController.h"
#import "FMSidePanelNavView.h"
#import "FMApplication.h"
#import "FMUser.h"


@implementation FMSidePanelRightViewController {
@private
    NSArray *_tapData;
    __weak FMSidePanelNavView *_sidePanelNavView;
}

@synthesize sidePanelNavView = _sidePanelNavView;

- (id)initWithTap:(NSArray *)tapData {
    self = [super init];
    if (self) {
        _tapData = tapData;
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];

    FMSidePanelNavView *sidePanelNavView = [[FMSidePanelNavView alloc]
            initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20)
                  tapData:_tapData];
    [self.view addSubview:sidePanelNavView];
    _sidePanelNavView = sidePanelNavView;

    if ([FMApplication instance].loginUser.isLogin) {
        TBMBGlobalSendNotificationForSEL(@selector($$getMessageUnreadCount:));
    }
}

@end