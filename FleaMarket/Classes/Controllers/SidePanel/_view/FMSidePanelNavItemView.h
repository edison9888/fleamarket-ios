//
//  FMSidePanelNavItemView.h
//  FleaMarket
//
//  Created by Caiyu on 13-7-15.
//  Copyright (c) 2013年 taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSidePanelNavSpace         7
#define kSidePanelNavItemWidth     117
#define kSidePanelNavItemHeight    117
#define kSidePanelNavItemStartX    ((FM_SCREEN_WIDTH - kSidePanelNavItemWidth * 2 - kSidePanelNavSpace) / 2  \
                                   + kSidePanelRightFixedWidth / 2)
#define kSidePanelNavItemStartY    (44.5 + (FM_SCREEN_HEIGHT - 480) / 2)

@class FMRootViewControllerDO;

@interface FMSidePanelNavItemView : UIButton

@property (nonatomic, strong) FMRootViewControllerDO *dataDO;
@property (nonatomic, assign) NSInteger unreadCount;

- (void)setClickItemBlock:(void(^)(FMSidePanelNavItemView * ))block;

- (void)buttonAnimation:(BOOL)isAnimation;

@end
