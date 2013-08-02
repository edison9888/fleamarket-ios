// 
// Created by henson on 7/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import "FMHomeThreeItemsCell.h"
#import "FMHomeItemView.h"
#import "FMHomeItemDO.h"

@implementation FMHomeThreeItemsCell {
    FMHomeItemView *_leftItemView;
    FMHomeItemView *_middleItemView;
    FMHomeItemView *_rightItemView;

    void (^_touchActionBlock)(FMHomeItemDO *homeItemDO);
    FMHomeRowDO *_rowDO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        __weak FMHomeThreeItemsCell *selfWeak = self;

        CGRect leftRect = {{8,8}, {98, 98}};
        FMHomeItemView *leftItemView = [self createItemView];
        leftItemView.frame = leftRect;
        leftItemView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:leftItemView];
        _leftItemView = leftItemView;

        CGRect middleRect = {{leftRect.origin.x + leftRect.size.width + 6,leftRect.origin.y}, {96, 97}};
        FMHomeItemView *middleItemView = [self createItemView];
        middleItemView.frame = middleRect;
        middleItemView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:middleItemView];
        _middleItemView = middleItemView;

        CGRect rightRect = {{middleRect.origin.x + middleRect.size.width + 6,middleRect.origin.y}, {98, 97}};
        FMHomeItemView *rightItemView = [self createItemView];
        rightItemView.frame = rightRect;
        rightItemView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak onTouchDownAction:set
                              withEvent:event];
        };
        [self.contentView addSubview:rightItemView];
        _rightItemView = rightItemView;
    }

    return self;
}

- (void)setData:(FMHomeRowDO *)rowDO {
    if (rowDO == _rowDO) {
        return;
    }
    _rowDO = rowDO;
    FMHomeItemDO *homeItemDO1 = rowDO.items.count
            > 0 ? [rowDO.items objectAtIndex:0] : nil;

    FMHomeItemDO *homeItemDO2 = rowDO.items.count
            > 1 ? [rowDO.items objectAtIndex:1] : nil;

    FMHomeItemDO *homeItemDO3 = rowDO.items.count
            > 2 ? [rowDO.items objectAtIndex:2] : nil;

    [_leftItemView setHomeItemDO:homeItemDO1];
    [_middleItemView setHomeItemDO:homeItemDO2];
    [_rightItemView setHomeItemDO:homeItemDO3];
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

- (void)setTouchAction:(void (^)(FMHomeItemDO *homeItemDO))block {
    _touchActionBlock = block;
}

- (FMHomeItemView *)createItemView {
    FMHomeItemView *itemView = [[FMHomeItemView alloc] initWithFrame:CGRectZero];
    itemView.backgroundColor = [UIColor clearColor];
    return itemView;
}

@end