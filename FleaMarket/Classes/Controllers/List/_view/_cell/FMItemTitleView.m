//
// Created by yuanxiao on 13-7-11.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMItemTitleView.h"
#import "FMItemDO.h"

#define ListItemCellDecFont     FMFont(NO, 14)
#define ListItemCellTitleFont   FMFont(YES, 18)

@implementation FMItemTitleView {
@private
    UILabel *_titleLabel;
    UILabel *_decLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = ListItemCellTitleFont;
        [self addSubview:_titleLabel];

        _decLabel = [[UILabel alloc] init];
        _decLabel.backgroundColor = [UIColor clearColor];
        _decLabel.font = ListItemCellDecFont;
        _decLabel.textColor = FMColorWithRed(0x3b, 0x3b, 0x3b);
        [self addSubview:_decLabel];
    }
    return self;
}

- (CGFloat)setItemDO:(FMItemDO *)itemDO withType:(FMItemTitleViewType)type {
    CGFloat startY;
    if (itemDO.voiceUrl) {
        startY = 40;
    } else {
        startY = 22;
    }
    _titleLabel.text = itemDO.title;
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(300 - 24, 300)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(12, startY, 300 - 24, size.height);

    if (type == FMItemTitleViewTypeList) {
        _decLabel.numberOfLines = 2;
    } else if (type == FMItemTitleViewTypeDetail) {
        _decLabel.numberOfLines = 3;
    }
    _decLabel.text = itemDO.description;
    size = [_decLabel.text sizeWithFont:_decLabel.font
                      constrainedToSize:CGSizeMake(300 - 24, 300)
                          lineBreakMode:NSLineBreakByWordWrapping];
    _decLabel.frame = CGRectMake(12, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 5,
            300 - 24, size.height > 35 ? 35 : size.height);

    return _decLabel.frame.origin.y + _decLabel.frame.size.height + 35;
}

+ (CGFloat)getHeight:(FMItemDO *)itemDO {
    CGFloat height;
    if (itemDO.voiceUrl) {
        height = 40;
    } else {
        height = 22;
    }
    CGSize size = [itemDO.title sizeWithFont:ListItemCellTitleFont
                               constrainedToSize:CGSizeMake(300 - 24, 300)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + 5;
    size = [itemDO.description sizeWithFont:ListItemCellDecFont
                      constrainedToSize:CGSizeMake(300 - 24, 300)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height > 35 ? 35 : size.height;
    return height + 35;
}

@end