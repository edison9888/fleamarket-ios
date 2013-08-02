// 
// Created by henson on 6/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import "FMItemDetailInfoView.h"
#import "FMItemDetailImageView.h"
#import "FMItemDO.h"
#import "FMItemDetailTitleDescriptionView.h"
#import "FMItemDetailBoughtView.h"
#import "FMVoiceButton.h"
#import "UIView+Helper.h"
#import "FMItemBaseView.h"
#import "FMAvatarImageView.h"

@implementation FMItemDetailInfoView {
    FMItemDetailImageView *_itemDetailImageView;
    FMVoiceButton *_voiceButton;

    FMItemDetailTitleDescriptionView *_titleDescriptionView;
    FMItemDetailBoughtView *_itemDetailBoughtView;
    UIImageView *_shadowImageView;
    FMItemBaseView *_itemBaseView;

    FMAvatarImageView *_avatarImageView;
    UIView *_verticalView;

    FMItemDO *_itemDO;

    void (^_boughtViewTouchBlock)(void);
    void (^_descriptionTouchBlock)(void);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __weak FMItemDetailInfoView *selfWeak = self;

        FMItemDetailImageView *itemDetailImageView = [[FMItemDetailImageView alloc] initWithFrame:CGRectZero];
        itemDetailImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:itemDetailImageView];
        _itemDetailImageView = itemDetailImageView;

        FMItemDetailTitleDescriptionView *titleDescriptionView = [[FMItemDetailTitleDescriptionView alloc] initWithFrame:CGRectZero];
        titleDescriptionView.backgroundColor = [UIColor whiteColor];
        [titleDescriptionView setDescriptionTouchAction:^{
            [selfWeak descriptionTouchAction];
        }];
        [self addSubview:titleDescriptionView];
        _titleDescriptionView = titleDescriptionView;

        FMVoiceButton *voiceButton = [[FMVoiceButton alloc] initWithFrame:CGRectZero];
        voiceButton.backgroundColor = [UIColor clearColor];
        voiceButton.hidden = YES;
        [self addSubview:voiceButton];
        _voiceButton = voiceButton;

        FMItemDetailBoughtView *itemDetailBoughtView = [[FMItemDetailBoughtView alloc] initWithFrame:CGRectZero];
        itemDetailBoughtView.backgroundColor = [UIColor whiteColor];
        itemDetailBoughtView.hidden = YES;
        __weak FMItemDetailBoughtView *detailBoughtViewWeak = itemDetailBoughtView;
        itemDetailBoughtView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            detailBoughtViewWeak.backgroundColor = [UIColor whiteColor];
            [selfWeak boughtTouchAction];
        };
        [self addSubview:itemDetailBoughtView];
        _itemDetailBoughtView = itemDetailBoughtView;

        _itemBaseView = [[FMItemBaseView alloc] initWithFrame:CGRectZero];
        _itemBaseView.backgroundColor = FMColorWithRed(243, 243, 243);
        _itemBaseView.from = kFMItemBaseViewFromDetail;
        [self addSubview:_itemBaseView];

        UIImage *shadowImage = [[UIImage imageNamed:@"item_shadow.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        shadowImageView.frame = CGRectZero;
        [self addSubview:shadowImageView];
        _shadowImageView = shadowImageView;

        FMAvatarImageView *avatarImageView = [[FMAvatarImageView alloc] initWithFrame:CGRectZero];
        avatarImageView.userInteractionEnabled = YES;
        avatarImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:avatarImageView];
        _avatarImageView = avatarImageView;

        UIView *verticalView = [[UIView alloc] initWithFrame:CGRectZero];
        verticalView.backgroundColor = FMColorWithRed(216, 216, 216);
        [self addSubview:verticalView];
        _verticalView = verticalView;
    }

    return self;
}

- (void)descriptionTouchAction {
    if (_descriptionTouchBlock) {
        _descriptionTouchBlock();
    }
}

- (void)setDescriptionTouchAction:(void (^)(void))block {
    _descriptionTouchBlock = block;
}

- (void)boughtTouchAction {
    if (_boughtViewTouchBlock) {
        _boughtViewTouchBlock();
    }
}

- (void)setBoughtTouchAction:(void (^)(void))block {
    _boughtViewTouchBlock = block;
}

+ (float)viewHeight:(FMItemDO *)itemDO {
    float viewHeight = 0;
    viewHeight += [FMItemDetailImageView viewHeight:itemDO];  //图片高度
//    viewHeight += [itemDO isVoiceEmpty] ? 58 : 67;

    // title&desc高度
    viewHeight += [FMItemDetailTitleDescriptionView viewHeight:itemDO];

    // 转卖高度
    if ([itemDO hasResellData]) {
        viewHeight += 34 + 40;
    }

    //基本信息高度
    viewHeight += 57;
    return viewHeight;
}

- (void)setItemDO:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    _itemDO = itemDO;

    [_itemDetailImageView setItemDO:_itemDO];
    float imageViewHeight = [FMItemDetailImageView viewHeight:_itemDO];
    CGRect imageViewRect = {{0,0},{FM_SCREEN_WIDTH, imageViewHeight}};
    _itemDetailImageView.frame = imageViewRect;

    if ([_itemDO isVoiceEmpty]) {
        [_voiceButton setVoiceUrl:nil];
        _voiceButton.hidden = YES;
    } else {
        [_voiceButton setVoiceUrl:_itemDO.voiceUrl];
        _voiceButton.hidden = NO;
        _voiceButton.frame = CGRectMake((FM_SCREEN_WIDTH - 68)/2.f, imageViewHeight-17, 68, 36);
    }

    [_titleDescriptionView setItemDO:_itemDO serverTime:serverTime];
    float titleDescriptionHeight = [FMItemDetailTitleDescriptionView viewHeight:_itemDO];
    CGRect titleRect = {{0, imageViewHeight}, {FM_SCREEN_WIDTH, titleDescriptionHeight}};
    _titleDescriptionView.frame = titleRect;

    CGRect boughtRect;
    if ([itemDO hasResellData]) {
        _itemDetailBoughtView.hidden = NO;
        [_itemDetailBoughtView setItemDO:_itemDO];
        boughtRect = CGRectMake(0, titleRect.origin.y + titleRect.size.height, FM_SCREEN_WIDTH, 34 + 40);
        _itemDetailBoughtView.frame = boughtRect;
    } else {
        boughtRect = CGRectMake(0, titleRect.origin.y + titleRect.size.height, 0, 0);
        _itemDetailBoughtView.hidden = YES;
    }

    float gap = 0;
    CGRect shadowRect = {{0, boughtRect.origin.y + boughtRect.size.height + gap}, {FM_SCREEN_WIDTH, 2}};
    _shadowImageView.frame = shadowRect;

    _itemBaseView.frame = CGRectMake(0, shadowRect.origin.y + shadowRect.size.height - 2, FM_SCREEN_WIDTH, 57);
    [_itemBaseView setItemDO:itemDO serverTime:serverTime];

    _avatarImageView.itemDO = itemDO;
    CGRect avatarRect = {{13, shadowRect.origin.y + shadowRect.size.height - 20}, {63, 63}};
    _avatarImageView.frame = avatarRect;

    CGRect verticalRect = {{44.5,avatarRect.origin.y + avatarRect.size.height}, {3,12}};
    _verticalView.frame = verticalRect;
}

- (UIImage *)getFirstImage {
    return [_itemDetailImageView getFirstImage];
}

@end