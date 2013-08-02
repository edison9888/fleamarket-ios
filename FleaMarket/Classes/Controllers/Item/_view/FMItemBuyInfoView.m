// 
// Created by henson on 6/28/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemBuyInfoView.h"
#import "FMImageView.h"
#import "FMItemDO.h"

@implementation FMItemBuyInfoView {
    FMImageView *_itemImageView;
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UILabel *_locationLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect itemImageRect = {{10, 10}, {70, 70}};
        FMImageView *itemImageView = [[FMImageView alloc] initWithFrame:itemImageRect];
        itemImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:itemImageView];
        _itemImageView = itemImageView;

        CGRect titleRect = {{itemImageRect.origin.x + itemImageRect.size.width + 10,10}, {220, 20}};
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = FMFont(NO, 13.f);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = FMColorWithRed(51, 51, 51);
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        CGRect priceRect = {{titleRect.origin.x, 10+20},titleRect.size};
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceRect];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = FMColorWithRed(222, 80, 110);
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.font = FMFont(YES, 15.f);
        [self addSubview:priceLabel];
        _priceLabel = priceLabel;

        CGRect locationRect = {{titleRect.origin.x,63}, titleRect.size};
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:locationRect];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.textAlignment = NSTextAlignmentLeft;
        locationLabel.font = FMFont(NO, 13.f);
        locationLabel.textColor = FMColorWithRed(152, 152, 152);
        [self addSubview:locationLabel];
        _locationLabel = locationLabel;

        CGRect lineRect = {{0,89},{self.frame.size.width,1}};
        UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
        lineView.backgroundColor = FMColorWithRed(231, 230, 226);
        [self addSubview:lineView];
    }

    return self;
}

- (void)setItemDO:(FMItemDO *)itemDO {
    [_itemImageView setFMImageWithURL:itemDO.picUrl
                       imageScaleType:FMImageScale160x160
                     placeholderImage:nil];
    _titleLabel.text = itemDO.title;
    CGRect titleRect = _titleLabel.frame;
    titleRect.size.height = [self titleHeight];
    _titleLabel.frame = titleRect;

    CGRect priceRect = _priceLabel.frame;
    priceRect.origin.y = titleRect.origin.y + titleRect.size.height + 2;
    _priceLabel.frame = priceRect;

    _priceLabel.text = [NSString stringWithFormat:@"¥%@",itemDO.price];
    NSArray *array = @[[itemDO getLocationText],[itemDO getTradeTypeString]];
    _locationLabel.text = [array componentsJoinedByString:@" | "];
}

- (float)titleHeight {
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font
                                    constrainedToSize:CGSizeMake(220, 1000)
                                        lineBreakMode:_titleLabel.lineBreakMode];
    if (titleSize.height >= 32) {
        return 32;
    }
    return 18;
}

@end