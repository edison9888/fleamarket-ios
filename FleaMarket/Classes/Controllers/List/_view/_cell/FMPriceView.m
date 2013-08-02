//
// Created by yuanxiao on 13-7-11.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMPriceView.h"
#import "FMItemDO.h"
#import "FMGlowLabel.h"

@implementation FMPriceView {

@private
    FMGlowLabel *_priceLabel;
    FMGlowLabel *_originalPriceLabel;
    UIView *_linePrice;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _priceLabel = [[FMGlowLabel alloc] init];
        _priceLabel.font = FMFont(YES, 18);
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_priceLabel];

        _originalPriceLabel = [[FMGlowLabel alloc] init];
        _originalPriceLabel.font = FMFont(NO, 14);
        _originalPriceLabel.textColor = [UIColor whiteColor];
        _originalPriceLabel.backgroundColor = [UIColor clearColor];
        _originalPriceLabel.hidden = YES;
        [self addSubview:_originalPriceLabel];

        _linePrice = [[UIView alloc] init];
        _linePrice.backgroundColor = [UIColor whiteColor];
        _linePrice.hidden = YES;
        [_originalPriceLabel addSubview:_linePrice];
    }
    return self;
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _priceLabel.text = [NSString stringWithFormat:@"￥%@", itemDO.price];;
    CGSize size = [_priceLabel.text sizeWithFont:_priceLabel.font
                               constrainedToSize:CGSizeMake(self.frame.size.width, 30)
                                   lineBreakMode:NSLineBreakByWordWrapping];

    float h = [itemDO.originalPrice doubleValue] == 0.f ? 10 : 30;
    CGRect priceRect = CGRectMake(self.frame.size.width - size.width - 10, self.frame.size.height - size.height - h,
            size.width + 5, size.height);
    _priceLabel.frame = priceRect;

    if ([itemDO.originalPrice doubleValue] == 0.f) {
        _originalPriceLabel.hidden = YES;
        _linePrice.hidden = YES;
        return;
    }

    _originalPriceLabel.hidden = NO;
    _linePrice.hidden = NO;
    _originalPriceLabel.text = [NSString stringWithFormat:@"￥%@", itemDO.originalPrice];
    size = [_originalPriceLabel.text sizeWithFont:_originalPriceLabel.font
                                constrainedToSize:CGSizeMake(self.frame.size.width, 30)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _originalPriceLabel.frame = CGRectMake(self.frame.size.width - size.width - 10, priceRect.origin.y + priceRect.size.height,
            size.width + 5, size.height);
    _linePrice.frame = CGRectMake(0, size.height/2, size.width, 1);
}

@end