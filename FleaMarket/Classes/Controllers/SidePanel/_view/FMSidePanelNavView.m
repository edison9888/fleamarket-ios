//
// Created by yuanxiao on 13-6-7.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMSidePanelNavView.h"
#import "TBMBGlobalFacade.h"
#import "FMSidePanelNavItemView.h"

@implementation FMSidePanelNavView {
@private
    NSMutableArray *_itemsView;
}


- (id)initWithFrame:(CGRect)frame tapData:(NSArray *)tapData {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = FMColorWithRed(38, 38, 38);
        [self initNavViews:tapData];
    }
    return self;
}

- (void)initNavViews:(NSArray *)tapData {
    _itemsView = [NSMutableArray arrayWithCapacity:tapData.count];
    __weak FMSidePanelNavView *selfBlock = self;
    CGRect rect = CGRectMake(kSidePanelNavItemStartX, kSidePanelNavItemStartY,
            kSidePanelNavItemWidth, kSidePanelNavItemHeight);
    for (NSUInteger i = 0; i < tapData.count; i++) {
        if (i % 2 == 0) {
            rect.origin.x = kSidePanelNavItemStartX;
        } else {
            rect.origin.x = kSidePanelNavItemStartX + kSidePanelNavItemWidth + kSidePanelNavSpace;
        }

        if (i % 2 == 0 && i != 0) {
            rect.origin.y += kSidePanelNavItemHeight + kSidePanelNavSpace;
        }

        FMSidePanelNavItemView *itemView = [[FMSidePanelNavItemView alloc] initWithFrame:rect];
        itemView.dataDO = [tapData objectAtIndex:i];
        [itemView setClickItemBlock:^(FMSidePanelNavItemView *view) {
            [selfBlock selectedTabHelp:view];
        }];
        [self addSubview:itemView];
        [_itemsView addObject:itemView];
    }
    [self selectedTab:FMTapTypeHome];
}

- (void)setUnreadCount:(NSInteger)count {
    FMSidePanelNavItemView *itemView = [_itemsView objectAtIndex:FMTapTypeAccount];
    itemView.unreadCount = count;
}

- (void)selectedTab:(FMTapType)pTapType {
    if (pTapType == FMTapTypePost) {
        for (FMSidePanelNavItemView *vview in _itemsView) {
            if (pTapType == vview.dataDO.tapType) {
                [vview buttonAnimation:YES];
            } else {
                [vview buttonAnimation:NO];
            }
        }
    } else {
        for (FMSidePanelNavItemView *vview in _itemsView) {
            if (pTapType == vview.dataDO.tapType) {
                [vview setSelected:YES];
            } else {
                [vview setSelected:NO];
            }
        }
    }
}

- (void)selectedTabHelp:(FMSidePanelNavItemView *)view {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$selectedTab:navItemView:), view);
}

@end