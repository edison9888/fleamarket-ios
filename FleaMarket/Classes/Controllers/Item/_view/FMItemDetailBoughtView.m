// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemDetailBoughtView.h"
#import "FMItemDO.h"

@implementation FMItemDetailBoughtView {
    UIView *_topLineView;
    UIView *_bottomLineView;
    UILabel *_textLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        topLineView.backgroundColor = FMColorWithRed(209, 209, 209);
        [self addSubview:topLineView];
        _topLineView = topLineView;

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.text = @"....查看宝贝原购买信息";
        textLabel.textColor = FMColorWithRed(152, 152, 152);
        textLabel.font = FMFont(NO, 15);
        [self addSubview:textLabel];
        _textLabel = textLabel;

        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomLineView.backgroundColor = FMColorWithRed(209, 209, 209);
        [self addSubview:bottomLineView];
        _bottomLineView = bottomLineView;
    }

    return self;
}

- (void)layoutSubviews {
    _topLineView.frame = CGRectMake(22, 0, self.frame.size.width - 2 * 22, 1);
    _bottomLineView.frame = CGRectMake(22, 34 - 1, self.frame.size.width - 2 * 22, 1);
    _textLabel.frame = CGRectMake(22 + 18, 1, self.frame.size.width - (22 * 2 + 18), 32);
}

- (void)setItemDO:(FMItemDO *)itemDO {

}

@end