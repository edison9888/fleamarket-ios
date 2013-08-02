// 
// Created by henson on 6/26/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBUtil.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMPostRequiredInfoView.h"
#import "FMPostImageView.h"
#import "FMPostTitlePriceView.h"
#import "FMPostVoiceView.h"
#import "FMItemDO.h"
#import "FMPostResellPromptView.h"

@implementation FMPostRequiredInfoView {
    __weak FMPostImageView *_postImageView;
    FMPostTitlePriceView *_postTitlePriceView;
    FMPostVoiceView *_postVoiceView;
    FMPostTextIndicationView *_upIndicationView;
    FMPostResellPromptView *_resellView;

@private
    FMItemDO *_itemDO;
}

@synthesize itemDO = _itemDO;
@synthesize postImageView = _postImageView;

- (id)initWithFrame:(CGRect)frame
             itemDO:(FMItemDO *)itemDO
       isShowResell:(BOOL)isShow {
    self = [super initWithFrame:frame];
    if (self) {
        _itemDO = itemDO;
        TBMBAutoBindingKeyPath(self);
        if (isShow) {
            self.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);

            FMPostResellPromptView *resellView = [[FMPostResellPromptView alloc]
                    initWithFrame:CGRectMake(0, -60, FM_SCREEN_WIDTH, 60)];
            resellView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
                TBMBGlobalSendNotificationForSEL(@selector($$postResellPushNotification:));
            };
            [self addSubview:resellView];
            _resellView = resellView;
        }

        CGRect postImageRect = {{(FM_SCREEN_WIDTH - 120) / 2.f, 20}, {120, 100}};
        FMPostImageView *postImageView = [[FMPostImageView alloc] initWithFrame:postImageRect];
        [self addSubview:postImageView];
        _postImageView = postImageView;

        CGRect postTitlePriceRect = {{0, 140}, {FM_SCREEN_WIDTH, 95}};
        FMPostTitlePriceView *postTitlePriceView = [[FMPostTitlePriceView alloc] initWithFrame:postTitlePriceRect
                                                                                        itemDO:_itemDO];
        postTitlePriceView.backgroundColor = [UIColor clearColor];
        [self addSubview:postTitlePriceView];
        _postTitlePriceView = postTitlePriceView;

        CGRect voiceButtonRect = {{0, postTitlePriceRect.origin.y + postTitlePriceRect.size.height + 50}, {FM_SCREEN_WIDTH, 100}};
        FMPostVoiceView *postVoiceView = [[FMPostVoiceView alloc] initWithFrame:voiceButtonRect
                                                                         itemDO:_itemDO];
        postVoiceView.backgroundColor = [UIColor clearColor];
        [self addSubview:postVoiceView];
        _postVoiceView = postVoiceView;

        CGRect upIndicationRect = {{0, self.frame.size.height - 40}, {FM_SCREEN_WIDTH, 40}};
        FMPostTextIndicationView *upIndicationView = [[FMPostTextIndicationView alloc] initWithFrame:upIndicationRect
                                                                                                type:FMPostIndicationTypeUp];
        [self addSubview:upIndicationView];
        _upIndicationView = upIndicationView;
   }

    return self;
}

- (void)setTitleText:(NSString *)text {
    [_postTitlePriceView setTitleText:text];
}

- (void)setTextIndicationState:(FMPostIndicationState)state {
    [_upIndicationView setState:state];
}

- (void)refreshView {
    [_postTitlePriceView refreshView];
}

- (void)setResellPromptHidden:(BOOL)hidden {
    if (hidden) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self setContentOffset:CGPointMake(0, 0)];
                         } completion:nil];
        return;
    }
}

@end