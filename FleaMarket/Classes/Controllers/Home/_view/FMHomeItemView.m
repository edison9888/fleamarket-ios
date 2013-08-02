// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import "FMHomeItemView.h"
#import "FMHomeItemDO.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Helper.h"
#import "FMImageView.h"
#import "FMHomeScrollImageView.h"

#define kMaxNumberCount (999)
#define kHomeBigItemHeight (200)
#define kHomeItemIconViewWidth (38)

@implementation FMHomeItemIconView {
    __weak UIImageView *_iconImageView;
    __weak UILabel *_textLabel;
    FMHomeItemIconType _type;

@private
    NSString *_text;
    UIImage *_iconImage;
}

@synthesize text = _text;
@synthesize iconImage = _iconImage;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        _type = FMHomeItemIconNormal;

        CGRect imageRect = {{0, 0}, image.size};
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:imageRect];
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.image = image;
        [self addSubview:iconImageView];
        _iconImageView = iconImageView;

        CGRect labelRect = {{imageRect.origin.x + image.size.width + 5, 0.5}, {23, 9}};
        UILabel *textLabel = [[UILabel alloc] initWithFrame:labelRect];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = FMFont(NO, 10.f);
        textLabel.textColor = [UIColor whiteColor];
        [self addSubview:textLabel];
        _textLabel = textLabel;
    }

    return self;
}

- (void)setType:(FMHomeItemIconType)type {
    _type = type;

    if (_type == FMHomeItemIconVoice) {
        _textLabel.font = FMFont(YES, 14.f);
    }
}

- (void)setText:(NSString *)text {
    _text = [text mutableCopy];

    if (_type == FMHomeItemIconVoice) {
        _textLabel.text = [NSString stringWithFormat:@"%@\"",
                                                     _text];
        CGSize textSize = [self voiceTextSize:_textLabel.text];
        _textLabel.frame = CGRectMake(0, 2.5, textSize.width, 11);

        _iconImageView.frame = CGRectMake(textSize.width + 1, 2, 7, 11);
        return;
    }

    int textCount = [_text intValue];
    if (textCount > kMaxNumberCount) {
        _textLabel.text = [NSString stringWithFormat:@"%d+",
                                                     kMaxNumberCount];
        return;
    }
    _textLabel.text = _text;
}

- (CGSize)voiceTextSize:(NSString *)text {
    return [text sizeWithFont:FMFont(YES, 14)
            constrainedToSize:CGSizeMake(1000, 11)
                lineBreakMode:NSLineBreakByWordWrapping];
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    _iconImageView.image = iconImage;
}

@end


#define kHomeItemViewGap 10

@implementation FMHomeItemView {
    __weak FMHomeScrollImageView *_imageView;
    __weak FMImageView *_shadowImageView;
    __weak FMHomeItemIconView *_voiceIconView;
    __weak FMHomeItemIconView *_commentIconView;
    __weak FMHomeItemIconView *_favoriteIconView;
    FMHomeItemDO *_item;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;

        FMHomeScrollImageView *imageView = [[FMHomeScrollImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        _imageView = imageView;

        FMImageView *shadowImageView = [[FMImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:shadowImageView];
        _shadowImageView = shadowImageView;

        CGRect voiceRect = {{kHomeItemViewGap, 8}, {40, 15}};
        UIImage *voiceImage = [UIImage imageWithFileName:@"home_voice_icon.png"];
        FMHomeItemIconView *voiceIconView = [[FMHomeItemIconView alloc] initWithFrame:voiceRect
                                                                                image:voiceImage];

        [voiceIconView setType:FMHomeItemIconVoice];
        voiceIconView.backgroundColor = [UIColor clearColor];
        voiceIconView.hidden = YES;
        [self addSubview:voiceIconView];
        _voiceIconView = voiceIconView;

        CGRect commentRect = {{kHomeItemViewGap, frame.size.height - 6 - kHomeItemViewGap}, {kHomeItemIconViewWidth, kHomeItemViewGap}};
        FMHomeItemIconView *commentIconView = [[FMHomeItemIconView alloc] initWithFrame:commentRect
                                                                                  image:[UIImage imageWithFileName:@"home_comment_icon.png"]];
        commentIconView.backgroundColor = [UIColor clearColor];
        [self addSubview:commentIconView];
        _commentIconView = commentIconView;

        CGRect favoriteRect = {{15 + kHomeItemIconViewWidth, frame.size.height - 6 - kHomeItemViewGap}, {kHomeItemIconViewWidth, kHomeItemViewGap}};
        FMHomeItemIconView *favoriteIconView = [[FMHomeItemIconView alloc] initWithFrame:favoriteRect
                                                                                   image:[UIImage imageWithFileName:@"home_favorite_icon.png"]];
        favoriteIconView.backgroundColor = [UIColor clearColor];
        [self addSubview:favoriteIconView];
        _favoriteIconView = favoriteIconView;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _shadowImageView.image = [UIImage imageNamed:[self _getShadowImageName:self.bounds]];
    _shadowImageView.frame = self.bounds;

    CGRect commentRect = {{kHomeItemViewGap, self.bounds.size.height - 6 - kHomeItemViewGap}, {kHomeItemIconViewWidth, kHomeItemViewGap}};
    _commentIconView.frame = commentRect;

    CGRect favoriteRect = {{15 + kHomeItemIconViewWidth, self.bounds.size.height - 6 - kHomeItemViewGap}, {kHomeItemIconViewWidth, kHomeItemViewGap}};
    _favoriteIconView.frame = favoriteRect;
}

- (FMHomeItemDO *)homeItemDO {
    return _item;
}

- (void)setHomeItemDO:(FMHomeItemDO *)homeItemDO {
    _item = homeItemDO;
    if (!homeItemDO) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    _commentIconView.text = [homeItemDO.item.commentCount stringValue];
    _favoriteIconView.text = [homeItemDO.item.favCount stringValue];

    if ([homeItemDO.item.hasVoice boolValue]) {
        _voiceIconView.hidden = NO;
        if (homeItemDO.item.voiceTime && [homeItemDO.item.voiceTime intValue] > 0) {
            _voiceIconView.text = [homeItemDO.item.voiceTime stringValue];
        } else {
            _voiceIconView.text = @"";
        }
    } else {
        _voiceIconView.hidden = YES;
    }

    _imageView.frame = self.bounds;
    [_imageView setData:homeItemDO.picUrls
               isSquare:YES
         imageScaleType:self.bounds.size.width > 150 ? FMImageScale320x320 : FMImageScale200x200];
}

- (NSString *)_getShadowImageName:(CGRect)frame {
    if (frame.size.width == kHomeBigItemHeight) {
        return @"home_item_shadow_big.png";
    }
    return @"home_item_shadow_small.png";
}

@end