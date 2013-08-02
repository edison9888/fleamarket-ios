//
// Created by Caiyu on 13-7-15.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMRootViewController.h"

#define kSidePanelNavItemStart2X    40

#define tfX  kSidePanelNavItemWidth*2
#define tfY  kSidePanelNavItemHeight*2
#define tfScale 1
#define animateDuration 0.4

@class FMSidePanelNavItemView;

@interface FMMenuView : UIView

- (void)selectedTab:(FMTapType )pTapType;

- (void)setUnreadCount:(NSInteger)count;

- (id)initWithFrame:(CGRect)frame tapData:(NSArray *)tapData;

-(void)pinchAnimationSuperView:(UIView*)superview gesture:(UIPinchGestureRecognizer*)gesture;

@end