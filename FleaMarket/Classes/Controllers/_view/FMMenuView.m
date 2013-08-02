//
// Created by Caiyu on 13-7-15.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMMenuView.h"
#import "TBMBGlobalFacade.h"
#import "FMSidePanelNavItemView.h"

@implementation FMMenuView{
@private
NSMutableArray *_itemsView;
    BOOL showing;
}

- (id)initWithFrame:(CGRect)frame tapData:(NSArray *)tapData {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = FMColorWithRed(38, 38, 38);
        [self initNavViews:tapData];
        showing = NO;
    }
    return self;
}

- (void)initNavViews:(NSArray *)tapData {
    _itemsView = [NSMutableArray arrayWithCapacity:tapData.count];
    __weak FMMenuView *selfBlock = self;
    CGRect rect = CGRectMake(kSidePanelNavItemStart2X, kSidePanelNavItemStartY,
            kSidePanelNavItemWidth, kSidePanelNavItemHeight);
    for (NSUInteger i = 0; i < tapData.count; i++) {
        if (i % 2 == 0) {
            rect.origin.x = kSidePanelNavItemStart2X;
        } else {
            rect.origin.x = kSidePanelNavItemStart2X + kSidePanelNavItemWidth + kSidePanelNavSpace;
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

- (void)selectedTab:(FMTapType )pTapType {
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

- (void)setUnreadCount:(NSInteger)count {
    FMSidePanelNavItemView *itemView = [_itemsView objectAtIndex:FMTapTypeAccount];
    itemView.unreadCount = count;
}

- (void)selectedTabHelp:(FMSidePanelNavItemView *)view {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$selectedTab:navItemView:), view);
    [self menuStateHide:1];
}

-(void)pinchAnimationSuperView:(UIView*)superview gesture:(UIPinchGestureRecognizer*)gesture{
    if(gesture.scale>1){
        float(^zoomOut)(float) = ^(float scale){
            return scale-1;
        };
        for(NSInteger i=0;i<_itemsView.count;i++){
            [self setFramesI:i WithScale:gesture.scale Block:zoomOut];
        }
        self.alpha = 2-gesture.scale;
    }else{
        if (!showing) {
            [superview addSubview:self];
            float(^zoomIn)(float) = ^(float scale){
                return scale;
            };
            for(NSInteger i=0;i<_itemsView.count;i++){
                [self setFramesI:i WithScale:gesture.scale Block:zoomIn];
            }
            self.alpha = 1-gesture.scale;
        }
    }
    if(gesture.state == UIGestureRecognizerStateEnded){
        if(gesture.scale>=2){
            [self removeFromSuperview];
            showing = NO;
        }else if(gesture.scale<=0.5){
            [self menuStateShow:gesture.scale];
            showing =YES;
        }else if(gesture.scale>1){
            [self menuStateShow:(1-gesture.scale)];
            showing = YES;
        }else{
            [self menuStateHide:gesture.scale];
        }
    }
}

-(void)menuStateHide:(float)scale{
    [UIView animateWithDuration:(2-scale)*animateDuration animations:^{
        float(^hide)(float) = ^(float scale){
            return scale;
        };
        for(NSInteger i=0;i<_itemsView.count;i++){
            [self setFramesI:i WithScale:2 Block:hide];
        }
        self.alpha =0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        showing = NO;
    }];
}

-(void)menuStateShow:(float)scale{
    [UIView animateWithDuration:(1-scale)*animateDuration animations:^{
        float(^show)(float) = ^(float scale){
            return scale;
        };
        for(NSInteger i=0;i<_itemsView.count;i++){
            [self setFramesI:i WithScale:0 Block:show];
        }
        self.alpha =1;
    }];
}

-(void)setFramesI:(NSUInteger)i WithScale:(float)scale Block:(float (^)(float))block{
    UIView *menuView = [_itemsView objectAtIndex:i];
//    NSLog(@"shang：%d,mod:%d",(int)floorf(i/2),i%2);
    switch(i){
        case 0:
            menuView.frame = CGRectMake(kSidePanelNavItemStart2X-block(scale)*kSidePanelNavItemWidth, kSidePanelNavItemStartY-block(scale)*kSidePanelNavItemHeight, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        case 1:
            menuView.frame = CGRectMake((kSidePanelNavItemStart2X + kSidePanelNavItemWidth + kSidePanelNavSpace)+block(scale)*kSidePanelNavItemWidth, kSidePanelNavItemStartY-block(scale)*kSidePanelNavItemHeight, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        case 2:
            menuView.frame = CGRectMake(kSidePanelNavItemStart2X-block(scale)*kSidePanelNavItemWidth,kSidePanelNavItemStartY+kSidePanelNavItemHeight + kSidePanelNavSpace, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        case 3:
            menuView.frame = CGRectMake((kSidePanelNavItemStart2X + kSidePanelNavItemWidth + kSidePanelNavSpace)+block(scale)*kSidePanelNavItemWidth,kSidePanelNavItemStartY+kSidePanelNavItemHeight + kSidePanelNavSpace, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        case 4:
            menuView.frame = CGRectMake(kSidePanelNavItemStart2X-block(scale)*kSidePanelNavItemWidth,kSidePanelNavItemStartY+2*kSidePanelNavItemHeight + 2*kSidePanelNavSpace+block(scale)*kSidePanelNavItemHeight, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        case 5:
            menuView.frame = CGRectMake((kSidePanelNavItemStart2X + kSidePanelNavItemWidth + kSidePanelNavSpace)+block(scale)*kSidePanelNavItemWidth,kSidePanelNavItemStartY+2*kSidePanelNavItemHeight + 2*kSidePanelNavSpace+block(scale)*kSidePanelNavItemHeight, kSidePanelNavItemWidth, kSidePanelNavItemHeight);
            break;
        default:
            break;
    }
}

@end