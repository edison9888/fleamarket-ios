//
// Created by yuanxiao on 13-7-17.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import "FMGuideController.h"
#import "FMGuideFirstView.h"
#import "FMGuideSecondView.h"
#import "FMGuideThirdView.h"
#import "FMSidePanelController.h"
#import "TBMBGlobalFacade.h"

#define kGuidePageCount   3

@implementation FMGuideController {
@private
    __weak UIScrollView *_guideScrollView;

    BOOL _isFirstOpenShow;
}

- (void)loadView {
    [super loadView];
    UIScrollView *guideScrollView = [[UIScrollView alloc] initWithFrame:
            CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [guideScrollView setShowsVerticalScrollIndicator:FALSE];
    [guideScrollView setShowsHorizontalScrollIndicator:FALSE];
    guideScrollView.directionalLockEnabled = YES;
    guideScrollView.alwaysBounceVertical = NO;
    [guideScrollView setBackgroundColor:[UIColor clearColor]];
    TBMBAutoNilDelegate(UIScrollView *, guideScrollView, delegate, self);
    guideScrollView.pagingEnabled = YES;
    _guideScrollView = guideScrollView;
    [self.view addSubview:guideScrollView];
    [self initGuideView];

    _isFirstOpenShow = YES;
}

- (void)initGuideView {
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    FMGuideFirstView *firstView = [[FMGuideFirstView alloc] initWithFrame:rect];
    [_guideScrollView addSubview:firstView];

    rect = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    FMGuideSecondView *secondView = [[FMGuideSecondView alloc] initWithFrame:rect];
    [_guideScrollView addSubview:secondView];

    rect = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
    FMGuideThirdView *thirdView = [[FMGuideThirdView alloc] initWithFrame:rect];
    [_guideScrollView addSubview:thirdView];

    _guideScrollView.contentSize = CGSizeMake(_guideScrollView.frame.size.width * kGuidePageCount, _guideScrollView.frame.size.height);
}

- (void)skipGuideView {
    if (!_isFirstOpenShow) {
        return;
    }
    _isFirstOpenShow = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FM_GUIDE_SHOW];

    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (!self.isFromAbout) {
        TBMBGlobalSendNotificationForSEL(@selector($$guideFinish));
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 self.fmSidePanelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                 self.fmSidePanelController.modalPresentationStyle = UIModalPresentationFullScreen;
                             }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint scrollOffset = scrollView.contentOffset;

    if (scrollOffset.x > FM_SCREEN_WIDTH * (kGuidePageCount - 1) + 50) {
        [self skipGuideView];
    }
}

@end