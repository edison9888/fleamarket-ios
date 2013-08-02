// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import "FMItemStarShareView.h"
#import "UIImage+Helper.h"
#import "FMItemDO.h"
#import "NSString+Helper.h"

#define kMaxFaviCount (999)
#define kFavoriteCountLabelFont (12)
#define kFavoriteCountLabelHeight (10)

@implementation FMItemStarShareView {
    __weak UIImageView *_starBgImageView;
    __weak UIImageView *_starImageView;
    __weak UILabel *_starCountLabel;
    __weak UIImageView *_shareBgImageView;

    FMItemDO *_itemDO;

    BOOL _isAnimating;
    void (^_favoriteActionBlock)(FMItemStarShareView*, FMItemDO *);
    void (^_shareActionBlock)(FMItemStarShareView*, FMItemDO *);
@private
    BOOL _isStar;
}

@synthesize isStar = _isStar;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isStar = NO;
        _isAnimating = NO;
        __weak FMItemStarShareView *selfWeak = self;

        UIImage *starBgImage = [self _starBgImage];
        CGRect starBgRect = {self.bounds.origin, starBgImage.size};
        UIImageView *starBgImageView = [[UIImageView alloc] initWithImage:starBgImage];
        starBgImageView.backgroundColor = [UIColor clearColor];
        starBgImageView.frame = starBgRect;
        starBgImageView.userInteractionEnabled = YES;
        starBgImageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak starAction];
        };
        [self addSubview:starBgImageView];
        _starBgImageView = starBgImageView;

        UIImage *starImage = [self _starImage];
        CGRect starRect = {{8, 6}, starImage.size};
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
        starImageView.backgroundColor = [UIColor clearColor];
        starImageView.frame = starRect;
        [_starBgImageView addSubview:starImageView];
        _starImageView = starImageView;

        CGRect starLabel = {{8 + starImage.size.width + 5, 9}, {40, kFavoriteCountLabelHeight}};
        UILabel *starCountLabel = [[UILabel alloc] initWithFrame:starLabel];
        starCountLabel.backgroundColor = [UIColor clearColor];
        starCountLabel.textColor = [UIColor whiteColor];
        starCountLabel.font = FMFont(YES, kFavoriteCountLabelFont);
        [self addSubview:starCountLabel];
        _starCountLabel = starCountLabel;

        UIImage *shareBgImage = [self _shareBgImage];
        CGRect shareBgRect = {{47, 0}, shareBgImage.size};
        UIImageView *shareBgImageView = [[UIImageView alloc] initWithFrame:shareBgRect];
        shareBgImageView.image = shareBgImage;
        shareBgImageView.backgroundColor = [UIColor clearColor];
        shareBgImageView.userInteractionEnabled = YES;
        shareBgImageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak favoriteAction];
        };
        [self addSubview:shareBgImageView];
        _shareBgImageView = shareBgImageView;

        UIImage *shareImage = [self _shareImage];
        UIImageView *shareImageView = [[UIImageView alloc] initWithImage:shareImage];
        shareImageView.backgroundColor = [UIColor clearColor];
        shareImageView.frame = CGRectMake(12, 6, shareImage.size.width, shareImage.size.height);
        [_shareBgImageView addSubview:shareImageView];
    }

    return self;
}

+ (float)viewWidth:(FMItemDO *)itemDO {
    NSString *faviCount = itemDO.collectNum;

    NSString *faviText = [NSString stringWithFormat:@"%@", faviCount];

    if (!faviCount || [faviCount isBlank]) {
        faviText = @"0";
    }

    if ([faviCount intValue] > kMaxFaviCount) {
        faviText = [NSString stringWithFormat:@"%d+", kMaxFaviCount];
    }

    return [FMItemStarShareView faviCountSize:faviText].width + 71;
}

- (void)starAction {
    if (_isAnimating) {
        return;
    }

    if (_favoriteActionBlock) {
        _favoriteActionBlock(self, _itemDO);
    }

    [self setIsStar:!(_isStar)];
    [UIView animateWithDuration:0.3
            animations:^{
                _isAnimating = YES;
                CGRect starRect = {{5, 3}, [self _starImage].size.width + 6, [self _starImage].size.height + 6};
                _starImageView.frame = starRect;
            } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 CGRect starRect = {{8, 6}, [self _starImage].size};
                                 _starImageView.frame = starRect;
                                 _isAnimating = NO;
                             }];
        }
    }];
}

- (void)favoriteAction {
    if (_shareActionBlock) {
        _shareActionBlock(self, _itemDO);
    }
}

- (void)setFavoriteAction:(void (^)(FMItemStarShareView *, FMItemDO *))block {
    _favoriteActionBlock = block;
}

- (void)setShareAction:(void (^)(FMItemStarShareView *, FMItemDO *))block {
    _shareActionBlock = block;
}

- (void)setIsStar:(BOOL)isStar {
    _isStar = isStar;

    _starImageView.image = isStar ? [self _starHighlightImage] : [self _starImage];
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;

    _starCountLabel.text = [self faviCountString:itemDO.collectNum];
    CGSize countSize = [FMItemStarShareView faviCountSize:_starCountLabel.text];
    CGRect countFrame = _starCountLabel.frame;
    countFrame.size.width = countSize.width;
    _starCountLabel.frame = countFrame;

    CGRect starBgRect = _starBgImageView.frame;
    starBgRect.size.width = 37 + [FMItemStarShareView faviCountSize:_starCountLabel.text].width;
    _starBgImageView.frame = starBgRect;

    CGRect shareRect = _shareBgImageView.frame;
    shareRect.origin.x = starBgRect.size.width - 2;
    _shareBgImageView.frame = shareRect;
}

- (NSString *)faviCountString:(NSString *)faviCount {
    if (!faviCount || [faviCount isBlank]) {
        return @"0";
    }

    if ([faviCount intValue] > kMaxFaviCount) {
        return [NSString stringWithFormat:@"%d+", kMaxFaviCount];
    }

    return faviCount;
}

+ (CGSize)faviCountSize:(NSString *)faviCount {
    if (!faviCount || [faviCount isBlank]) {
        return CGSizeZero;
    }
    return [faviCount sizeWithFont:FMFont(YES, kFavoriteCountLabelFont)
                 constrainedToSize:CGSizeMake(1000, kFavoriteCountLabelHeight)
                     lineBreakMode:NSLineBreakByWordWrapping];
}

- (UIImage *)_starBgImage {
    return [[UIImage imageWithFileName:@"star_bg_image.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
}

- (UIImage *)_shareBgImage {
    return [UIImage imageWithFileName:@"share_bg_image.png"];
}

- (UIImage *)_starImage {
    return [UIImage imageWithFileName:@"star_icon.png"];
}

- (UIImage *)_starHighlightImage {
    return [UIImage imageWithFileName:@"star_highlight_icon.png"];
}

- (UIImage *)_shareImage {
    return [UIImage imageWithFileName:@"share_icon.png"];
}

@end