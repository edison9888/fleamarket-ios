// 
// Created by henson on 6/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#define kMaxDescriptionSizeHeight  (90.f)

#import <BlocksKit/UIView+BlocksKit.h>
#import "FMItemDetailTitleDescriptionView.h"
#import "FMItemDO.h"
#import "NSString+Helper.h"
#import "UIView+Helper.h"

@implementation FMItemDetailTitleDescriptionView {
    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    UILabel *_viewMoreLabel;
    void (^_descriptionTouchActionBlock)(void);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __weak FMItemDetailTitleDescriptionView *selfWeak = self;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = FMFont(YES, 18);
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.font = FMFont(NO, 14.f);
        descriptionLabel.numberOfLines = 5;
        descriptionLabel.userInteractionEnabled = YES;
        descriptionLabel.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak descriptionTouchAction];
        };
        [self addSubview:descriptionLabel];
        _descriptionLabel = descriptionLabel;

        UILabel *viewMoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        viewMoreLabel.backgroundColor = [UIColor clearColor];
        viewMoreLabel.font = FMFont(NO, 14);
        viewMoreLabel.text = @"查看更多 >>";
        viewMoreLabel.textColor = FMColorWithRed(152, 152, 152);
        viewMoreLabel.textAlignment = NSTextAlignmentLeft;
        viewMoreLabel.userInteractionEnabled = YES;
        viewMoreLabel.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak descriptionTouchAction];
        };
        [self addSubview:viewMoreLabel];
        _viewMoreLabel = viewMoreLabel;
    }

    return self;
}

- (void)descriptionTouchAction {
    if (_descriptionTouchActionBlock) {
        _descriptionTouchActionBlock();
    }
}

- (void)setDescriptionTouchAction:(void (^)(void))block {
    _descriptionTouchActionBlock = block;
}

+ (float)viewHeight:(FMItemDO *)itemDO {
    CGSize titleSize = [itemDO.title sizeWithFont:FMFont(YES, 18)
                        constrainedToSize:CGSizeMake(FM_SCREEN_WIDTH - 22 * 2, 1000)
                            lineBreakMode:NSLineBreakByWordWrapping];

    NSString *descText = [itemDO.description isNotBlank] ? itemDO.description : kItemDefaultDescriptionText;
    CGSize descriptionSize = [descText sizeWithFont: FMFont(NO, 14.f)
                                      constrainedToSize:CGSizeMake(FM_SCREEN_WIDTH - 22 * 2, 1000)
                                          lineBreakMode:NSLineBreakByWordWrapping];
    if (descriptionSize.height > kMaxDescriptionSizeHeight) {
        descriptionSize.height = kMaxDescriptionSizeHeight;
    }

    return 40 + titleSize.height + 6 + descriptionSize.height + 5 + 15 + 30;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setItemDO:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    _titleLabel.text = itemDO.title;
    CGSize titleSize = [self textSize:_titleLabel.text font:_titleLabel.font];
    CGRect titleRect = {{22, 38}, {FM_SCREEN_WIDTH - 22 * 2, titleSize.height}};
    _titleLabel.frame = titleRect;

    _descriptionLabel.text = [itemDO.description isNotBlank] ? itemDO.description : kItemDefaultDescriptionText;

    CGSize descriptionSize = [self descriptionSize];
    CGRect descriptionRect = {{22, titleRect.origin.y + titleRect.size.height + 6}, {FM_SCREEN_WIDTH - 22 * 2, descriptionSize.height}};
    _descriptionLabel.frame = descriptionRect;

    CGRect moreRect = {{descriptionRect.origin.x, descriptionRect.origin.y + descriptionRect.size.height + 8}, {100, 15}};
    _viewMoreLabel.frame = moreRect;
}

- (CGSize)textSize:(NSString *)text font:(UIFont *)font {
   return [text sizeWithFont:font
           constrainedToSize:CGSizeMake(FM_SCREEN_WIDTH - 2 * 22, 1000)
               lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)descriptionSize {
    CGSize descriptionSize = [self textSize:_descriptionLabel.text font:_descriptionLabel.font];
    if (descriptionSize.height > kMaxDescriptionSizeHeight) {
        descriptionSize.height = kMaxDescriptionSizeHeight;
    }
    return descriptionSize;
}

@end