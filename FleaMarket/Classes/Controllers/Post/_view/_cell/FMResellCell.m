// 
// Created by henson on 7/31/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMResellCell.h"
#import "FMImageView.h"
#import "FMTaoBaoTrade.h"
#import "UIImage+Helper.h"

@implementation FMResellCellBackgroundView {
    UIImageView *_shadowImageView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 1)];
        topLine.backgroundColor = FMColorWithRed(218, 218, 218);
        [self addSubview:topLine];

        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 91)];
        leftLine.backgroundColor = FMColorWithRed(218, 218, 218);
        [self addSubview:leftLine];

        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(300 - 1, 0, 1,91)];
        rightLine.backgroundColor = FMColorWithRed(218, 218, 218);
        [self addSubview:rightLine];

        CGRect shadowRect = {{0, 90}, {300, 2}};
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:shadowRect];
        shadowImageView.image = [[UIImage imageNamed:@"item_shadow.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        shadowImageView.hidden = YES;
        [self addSubview:shadowImageView];
        _shadowImageView = shadowImageView;
    }

    return self;
}

- (void)setBottomLineHidden:(BOOL)hidden {
    _shadowImageView.hidden = hidden;
}

@end

@implementation FMResellCell {
    FMImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UIButton *_postTimeLabel;
    UIButton *_resellButton;

    FMTaoBaoTradeOrder *_order;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect imageRect = {{10, 10}, {70, 70}};
        FMImageView *imageView = [[FMImageView alloc] initWithFrame:imageRect];
        [self.contentView addSubview:imageView];
        _imageView = imageView;

        CGRect titleRect = {{90, 15}, {200, 20}};
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = FMFont(NO, 14.f);
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;

        CGRect priceRect = {{90, 40}, {135, 20}};
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceRect];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = FMColorWithRed(213, 97, 78);
        priceLabel.font = FMFont(YES, 14);
        [self.contentView addSubview:priceLabel];
        _priceLabel = priceLabel;

        CGRect postTimeRect = {{90, 62}, {135, 14}};
        UIButton *postTimeLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        postTimeLabel.frame = postTimeRect;
        postTimeLabel.titleLabel.font = FMFont(NO, 10);
        [postTimeLabel setTitleColor:FMColorWithRed(152, 152, 152) forState:UIControlStateNormal];
        postTimeLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        postTimeLabel.backgroundColor = [UIColor clearColor];
        [postTimeLabel setImage:[self _postTimeImage] forState:UIControlStateNormal];
        [postTimeLabel setImage:[self _postTimeImage] forState:UIControlStateHighlighted];
        [postTimeLabel setTitleEdgeInsets:UIEdgeInsetsMake(2, 3, 0, 0)];
        [postTimeLabel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [self.contentView addSubview:postTimeLabel];
        _postTimeLabel = postTimeLabel;

        CGRect resellRect = {{230, 45}, {60, 29}};
        UIButton *resellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resellButton.frame = resellRect;
        resellButton.titleLabel.font = FMFont(NO, 12);
        resellButton.backgroundColor = [UIColor clearColor];
        [resellButton setTitle:@"一键转卖" forState:UIControlStateNormal];
        [self.contentView addSubview:resellButton];
        _resellButton = resellButton;
    }

    return self;
}

- (void)setOrder:(FMTaoBaoTradeOrder *)order endTime:(NSString *)endTime {
    if (_order == order) {
        return;
    }

    _order = order;
    [_imageView setWebPImageWithURL:order.picUrl
                     imageScaleType:FMImageScale160x160
                   placeholderImage:FMPlaceholderImage
                         isProgress:NO];

    _titleLabel.text = order.title;
    _priceLabel.text = [NSString stringWithFormat:@"￥%@", order.price];
   [_postTimeLabel setTitle:endTime forState:UIControlStateNormal];

    NSString *buttonTitle;
    UIColor *textColor;
    if (order.virtual) {
        buttonTitle = @"虚拟宝贝";
        _resellButton.enabled = NO;
        textColor = [UIColor grayColor];
        [_resellButton setBackgroundImage:[[UIImage imageNamed:@"btn_gay.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(3.5, 3.5, 3.5, 3.5)]
                                 forState:UIControlStateNormal];
    }  else if (order.status == 1) {
        buttonTitle = @"正在转卖";
        textColor = [UIColor grayColor];
        _resellButton.enabled = NO;
        [_resellButton setBackgroundImage:[[UIImage imageNamed:@"btn_gay.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(3.5, 3.5, 3.5, 3.5)]
                                 forState:UIControlStateNormal];
    } else {
        buttonTitle = @"一键转卖";
        _resellButton.enabled = YES;
        textColor = [UIColor whiteColor];
        [_resellButton setBackgroundImage:[[UIImage imageWithFileName:@"post_resell_btn_bg.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]
                                forState:UIControlStateNormal];
        [_resellButton addTarget:self
                          action:@selector(resellAction)
                forControlEvents:UIControlEventTouchUpInside];
    }
    [_resellButton setTitleColor:textColor forState:UIControlStateNormal];
    [_resellButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)resellAction {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$postResellCellActionNotification:order:), _order);
}

- (UIImage *)_postTimeImage {
    return [UIImage imageNamed:@"post_time_icon.png"];
}

@end