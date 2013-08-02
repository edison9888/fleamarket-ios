//
//  FMBaseViewController.h
//  FleaMarket
//
//  Created by Henson on 5/28/13.
//  Copyright (c) 2013 taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMBDefaultRootViewController.h"
#import "UIImage+Helper.h"
#import "FMBaseBarView.h"

@class FMBasePageView;

@protocol FMNeedLoginProtocol
@end

@protocol FMNeedClosePanWithSidePanel
@end

@interface FMBaseViewController : TBMBDefaultRootViewController
@property(nonatomic, weak, readonly) UIButton *leftBarButton;
@property(nonatomic, weak, readonly) UIButton *rightBarButton;
@property(nonatomic, weak, readonly) FMBaseBarView *titleView;
@property(nonatomic, strong) FMBasePageView *page;
@property(nonatomic, strong) FMBaseBarViewDO *barViewDO;
@property(nonatomic, assign) BOOL showing;      //是否显示在屏幕的最上层，接收通知的时候需要判断

- (void)releaseViews;

- (void)leftAction:(id)sender;

- (void)rightAction:(id)sender;

- (void)setRightButtonTitle:(NSString *)title;

- (void)setRightButtonIconImage:(UIImage *)iconImage;

- (void)setRightButtonSelectIconImage:(UIImage *)iconImage;

- (void)setRightButtonTitle:(NSString *)title
            rightButtonType:(FMHeaderBarRightButtonType)rightButtonType
                  iconImage:(UIImage *)iconImage;

- (void)setLeftBarButtonTitle:(NSString *)title
                   buttonType:(FMHeaderBarLeftButtonType)buttonType
                    iconImage:(UIImage *)iconImage;

- (void)setTitle:(NSString *)title;

- (void)setTitleBg:(FMHeaderBarBGType)headerBarBGType;

//隐藏显示title notification
- (void)$$receiveScroll:(id <TBMBNotification>)notification offset:(NSNumber *)offset;

//loading
- (void)showPageLoadingView;

- (void)removePageLoadingView;

- (void)showPageLoadingText:(NSString *)text;

- (void)showRefreshPage:(void (^)(void))refreshBlock;

//login
- (void)pushViewControllerWithLogin:(UIViewController *)viewController animated:(BOOL)animated;

- (void)pushViewControllerWithLogin:(UIViewController *)viewController animated:(BOOL)animated
         withUINavigationController:(UINavigationController *)navigationController;

@end
