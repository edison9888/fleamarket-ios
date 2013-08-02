// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMHomeItemCell.h"
#import "FMHomeItemView.h"
#import "FMHomeItemDO.h"
#import "UIImageView+WebCache.h"
#import "FMHomeUserItemView.h"
#import "UIView+BlocksKit.h"
#import "FMHomeItemBannerView.h"

#define kHomeBarHeight (80)
#define kHomeBigItemWidth (200)
#define kHomeItemTopGap (8)
#define kHomeItemLeftGap (8)
#define kHomeItemGap (6)

@implementation FMHomeItemCell {
    __weak FMHomeItemView *_itemBigView;
    __weak FMHomeItemView *_itemSmallTopView;
    __weak FMHomeItemView *_itemSmallBottomView;
    __weak FMHomeItemBannerView *_itemBannerImageView;
    __weak FMHomeUserItemView *_userItemView;

    void (^_touchActionBlock)(FMHomeItemDO *homeItemDO);
    FMHomeRowDO *_rowDO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        __weak FMHomeItemCell *selfWeak = self;

        FMHomeItemView *itemBigView = [self setupHomeItemView];
        itemBigView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:itemBigView];
        _itemBigView = itemBigView;

        FMHomeItemView *itemSmallTopView = [self setupHomeItemView];
        itemSmallTopView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:itemSmallTopView];
        _itemSmallTopView = itemSmallTopView;

        FMHomeItemView *itemSmallBottomView = [self setupHomeItemView];
        itemSmallBottomView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:itemSmallBottomView];
        _itemSmallBottomView = itemSmallBottomView;

        CGRect itemBannerRect = {{kHomeItemLeftGap, kHomeItemTopGap}, {FM_SCREEN_WIDTH - kHomeItemLeftGap * 2, kHomeBarHeight}};
        FMHomeItemBannerView *itemBannerImageView = [[FMHomeItemBannerView alloc] initWithFrame:itemBannerRect];
        itemBannerImageView.hidden = YES;
        itemBannerImageView.userInteractionEnabled = YES;
        itemBannerImageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:itemBannerImageView];
        _itemBannerImageView = itemBannerImageView;

        FMHomeUserItemView *userItemView = [[FMHomeUserItemView alloc] initWithFrame:CGRectZero];
        userItemView.backgroundColor = [UIColor clearColor];
        userItemView.hidden = YES;
        userItemView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:userItemView];
        _userItemView = userItemView;
    }

    return self;
}

- (void)onTouchDownAction:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchActionBlock) {
        FMHomeItemDO *itemDO = nil;
        for (UITouch *t in touches) {
            if (t.view && [t.view conformsToProtocol:@protocol(FMHomeItemViewProtocol)]) {
                itemDO = ((id <FMHomeItemViewProtocol>) t.view).homeItemDO;
                if (itemDO) {
                    break;
                }
            }
        }
        _touchActionBlock(itemDO);
    }
}

- (FMHomeItemView *)setupHomeItemView {
    FMHomeItemView *homeItemView = [[FMHomeItemView alloc] initWithFrame:CGRectZero];
    homeItemView.backgroundColor = [UIColor clearColor];
    return homeItemView;
}

- (void)setTouchAction:(void (^)(FMHomeItemDO *homeItemDO))block {
    _touchActionBlock = block;
}

- (void)setData:(FMHomeRowDO *)rowDO {
    if (rowDO == _rowDO) {
        return;
    }
    _rowDO = rowDO;
    if (rowDO.type == FM_BANNER) {
        FMHomeItemDO *homeItemDO = rowDO.items.count
                > 0 ? [rowDO.items objectAtIndex:0] : nil;
        if (homeItemDO) {
            _itemBigView.hidden = YES;
            _itemSmallTopView.hidden = YES;
            _itemSmallBottomView.hidden = YES;
            _itemBannerImageView.hidden = NO;
            _userItemView.hidden = YES;
            [_itemBannerImageView setHomeItemDO:homeItemDO];

        } else {
            _itemBigView.hidden = YES;
            _itemSmallTopView.hidden = YES;
            _itemSmallBottomView.hidden = YES;
            _itemBannerImageView.hidden = YES;
            _userItemView.hidden = YES;
        }
        return;
    }

    if (rowDO.type == FM_LEFT_BIG) {

        //left big
        FMHomeItemDO *homeItemDO1 = rowDO.items.count
                > 0 ? [rowDO.items objectAtIndex:0] : nil;

        FMHomeItemDO *homeItemDO2 = rowDO.items.count
                > 1 ? [rowDO.items objectAtIndex:1] : nil;

        FMHomeItemDO *homeItemDO3 = rowDO.items.count
                > 2 ? [rowDO.items objectAtIndex:2] : nil;


        _itemBigView.hidden = NO;
        _itemSmallTopView.hidden = NO;
        _itemSmallBottomView.hidden = NO;
        _itemBannerImageView.hidden = YES;

        if (homeItemDO1.seller) {
            _userItemView.hidden = NO;
            _itemBigView.hidden = YES;
            _userItemView.frame = CGRectMake(kHomeItemLeftGap, kHomeItemTopGap, kHomeBigItemWidth, kHomeBigItemWidth);
            [_userItemView setHomeItemDO:homeItemDO1];
        } else {
            _userItemView.hidden = YES;
            _itemBigView.hidden = NO;
            _itemBigView.frame = CGRectMake(kHomeItemLeftGap, kHomeItemTopGap, kHomeBigItemWidth, kHomeBigItemWidth);
            [_itemBigView setHomeItemDO:homeItemDO1];
        }


        _itemSmallTopView.frame = CGRectMake(kHomeItemLeftGap + kHomeBigItemWidth + kHomeItemGap, kHomeItemTopGap, 98, 97);
        [_itemSmallTopView setHomeItemDO:homeItemDO2];

        _itemSmallBottomView.frame = CGRectMake(kHomeItemLeftGap + kHomeBigItemWidth + kHomeItemGap, kHomeItemTopGap + 97 + kHomeItemGap, 98, 97);
        [_itemSmallBottomView setHomeItemDO:homeItemDO3];
        return;
    }

    if (rowDO.type == FM_RIGHT_BIG) {

        FMHomeItemDO *homeItemDO1 = rowDO.items.count
                > 0 ? [rowDO.items objectAtIndex:0] : nil;

        FMHomeItemDO *homeItemDO2 = rowDO.items.count
                > 1 ? [rowDO.items objectAtIndex:1] : nil;

        FMHomeItemDO *homeItemDO3 = rowDO.items.count
                > 2 ? [rowDO.items objectAtIndex:2] : nil;


        _itemBigView.hidden = NO;
        _itemSmallTopView.hidden = NO;
        _itemSmallBottomView.hidden = NO;
        _itemBannerImageView.hidden = YES;
        _userItemView.hidden = YES;

        if (homeItemDO1.seller) {
            _userItemView.hidden = NO;
            _itemBigView.hidden = YES;
            _userItemView.frame = CGRectMake(8 + 98 + 6, 8, kHomeBigItemWidth, kHomeBigItemWidth);
            [_userItemView setHomeItemDO:homeItemDO1];
        } else {
            _userItemView.hidden = YES;
            _itemBigView.hidden = NO;
            _itemBigView.frame = CGRectMake(8 + 98 + 6, 8, kHomeBigItemWidth, kHomeBigItemWidth);
            [_itemBigView setHomeItemDO:homeItemDO1];
        }

        _itemSmallTopView.frame = CGRectMake(8, 8, 98, 97);
        [_itemSmallTopView setHomeItemDO:homeItemDO2];

        _itemSmallBottomView.frame = CGRectMake(8, 8 + 97 + 6, 98, 97);
        [_itemSmallBottomView setHomeItemDO:homeItemDO3];
        return;
    }

}

@end