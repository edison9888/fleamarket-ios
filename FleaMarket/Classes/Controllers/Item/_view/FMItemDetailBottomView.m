// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMItemDetailBottomView.h"
#import "UIImage+Helper.h"
#import "NSString+Helper.h"
#import "FMItemDO.h"
#import "FMApplication.h"
#import "FMUser.h"

#define kMaxBadge 999

@implementation FMItemDetailBottomItemView {
    UIImageView *_iconImageView;
    UIButton *_badgeView;
@private
    NSString *_badge;
}

@synthesize badge = _badge;

- (id)initWithIconImage:(UIImage *)iconImage {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.isHighlight = NO;
        self.iconImage = iconImage;

        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        iconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:iconImageView];
        _iconImageView = iconImageView;

        UIButton *badgeView = [UIButton buttonWithType:UIButtonTypeCustom];
        [badgeView setBackgroundImage:[self _getBadgeBgImage]
                             forState:UIControlStateNormal];
        [badgeView setBackgroundImage:[self _getBadgeBgImage]
                             forState:UIControlStateHighlighted];
        [badgeView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        badgeView.titleLabel.font = FMFont(NO, 9);
        badgeView.hidden = YES;
        badgeView.frame = CGRectMake(41.5, 8, 12, 12);
        badgeView.userInteractionEnabled = NO;
        [badgeView setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [self addSubview:badgeView];
        _badgeView = badgeView;
    }

    return self;
}

- (void)setIsHighlight:(BOOL)isHighlight {
    _isHighlight = isHighlight;

    if (self.highlightImage) {
        _iconImageView.image = isHighlight ? self.highlightImage : self.iconImage;
    }
}

- (void)addBadge {
    int badge = [_badge integerValue];
    [self setBadge:[NSString stringWithFormat:@"%d", badge + 1]];
}

- (void)reduceBadge {
    int badge = [_badge integerValue];
    [self setBadge:[NSString stringWithFormat:@"%d", badge - 1]];
}

- (UIImage *)_getBadgeBgImage {
    return [[UIImage imageNamed:@"item_detail_badge_bg.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 2)];
}

- (void)setBadge:(NSString *)badge {
    _badge = [badge mutableCopy];

    if (!_badge || [_badge isBlank] || [_badge intValue] <= 0) {
        _badgeView.hidden = YES;
        return;
    }
    _badgeView.hidden = NO;
    if ([_badge intValue] < 10) {
        [_badgeView setTitleEdgeInsets:UIEdgeInsetsMake(0, 2.5, 0, 0)];
    } else {
        [_badgeView setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    }
    CGSize badgeSize = [[self badgeString:_badge] sizeWithFont:_badgeView.titleLabel.font
                                             constrainedToSize:CGSizeMake(1000, 9)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
    CGRect badgeRect = _badgeView.frame;
    badgeRect.size.width = 8 + badgeSize.width > [self _getBadgeBgImage].size.width ? 8 + badgeSize.width : [self _getBadgeBgImage].size.width;
    _badgeView.frame = badgeRect;
    [_badgeView setTitle:[self badgeString:_badge] forState:UIControlStateNormal];
}

- (NSString *)badgeString:(NSString *)badge {
    if ([badge intValue] > kMaxBadge) {
        badge = [NSString stringWithFormat:@"%d+", kMaxBadge];
    }
    return badge;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _iconImageView.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
}

@end

#define kFavoriteItemTag (1001)
#define kCommentItemTag (1002)
#define kOperationItemTag (1003)

@implementation FMItemDetailBottomView {
    void (^_buyActionBlock)(void);
    void (^_shareActionBlock)(void);
    void (^_editActionBlock)(void);
    void (^_operationActionBlock)(void);

    UIButton *_buyButton;
    FMItemDO *_itemDO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.image = [self _getBottomBgImage];

        [self setupItemViews];

        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyButton setBackgroundImage:[UIImage imageWithFileName:@"item_detail_buy_bg.png"]
                             forState:UIControlStateNormal];
        [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buyButton.titleLabel.font = FMFont(YES, 15);
        [buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
        buyButton.hidden = YES;
        buyButton.frame = CGRectMake(FM_SCREEN_WIDTH - 80, 2.5, 80, 44.5);
        [buyButton addTarget:self
                      action:@selector(buyAction)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buyButton];
        _buyButton = buyButton;
    }

    return self;
}

- (void)setupItemViews {
    __weak FMItemDetailBottomView *selfWeak = self;

    UIImage *favoriteIconImage = [UIImage imageNamed:@"item_detail_favorite_icon.png"];
    FMItemDetailBottomItemView *favoriteItem = [[FMItemDetailBottomItemView alloc] initWithIconImage:favoriteIconImage];
    favoriteItem.highlightImage = [UIImage imageNamed:@"item_detail_favorite_icon_highlight.png"];
    favoriteItem.tag = kFavoriteItemTag;
    favoriteItem.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak favoriteAction];
    };

    UIImage *commentIconImage = [UIImage imageNamed:@"item_detail_comment_icon.png"];
    FMItemDetailBottomItemView *commentItem = [[FMItemDetailBottomItemView alloc] initWithIconImage:commentIconImage];
    commentItem.tag = kCommentItemTag;
    commentItem.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak commentAction];
    };

    UIImage *shareIconImage = [UIImage imageNamed:@"item_detail_share_icon.png"];
    FMItemDetailBottomItemView *shareItem = [[FMItemDetailBottomItemView alloc] initWithIconImage:shareIconImage];
    shareItem.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak shareAction];
    };

    UIImage *operationIconImage = [UIImage imageNamed:@"item_detail_operation_icon.png"];
    FMItemDetailBottomItemView *operationItem = [[FMItemDetailBottomItemView alloc] initWithIconImage:operationIconImage];
    operationItem.tag = kOperationItemTag;
    operationItem.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak operationAction];
    };

    [self setItems:@[favoriteItem, commentItem, shareItem, operationItem]];
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;

    _buyButton.hidden = [self isSeller];
    [self operationItem].hidden = ![self isSeller];

    [[self favoriteItem] setBadge:itemDO.collectNum];
    [[self commentItem] setBadge:itemDO.commentNum];
}

- (FMItemDetailBottomItemView *)favoriteItem {
    return (FMItemDetailBottomItemView *)[self viewWithTag:kFavoriteItemTag];
}

- (FMItemDetailBottomItemView *)commentItem {
    return (FMItemDetailBottomItemView *)[self viewWithTag:kCommentItemTag];
}

- (FMItemDetailBottomItemView *)operationItem {
    return (FMItemDetailBottomItemView *)[self viewWithTag:kOperationItemTag];
}

- (void)operationAction {
    if (_operationActionBlock) {
        _operationActionBlock();
    }
}

- (void)buyAction {
    if ([self isSeller] && _editActionBlock) {
        _editActionBlock();
        return;
    }

    if (_buyActionBlock) {
        _buyActionBlock();
    }
}

- (void)shareAction {
    if (_shareActionBlock) {
        _shareActionBlock();
    }
}

- (void)setIsFavorite:(BOOL)isFavorite {
    _isFavorite = isFavorite;

    FMItemDetailBottomItemView *favoriteItem = [self favoriteItem];
    if (isFavorite) {
        favoriteItem.isHighlight = YES;
        return;
    }
    favoriteItem.isHighlight = NO;
    return;
}

- (void)setSubscribed:(BOOL)isSubscribed {
    FMItemDetailBottomItemView *favoriteItem = [self favoriteItem];
    if (isSubscribed) {
        [favoriteItem addBadge];
        self.isFavorite = YES;
        return;
    }
    [favoriteItem reduceBadge];
    self.isFavorite = NO;
    return;
}

- (void)setFavoriteBadge:(NSString *)badge {
    FMItemDetailBottomItemView *favoriteItem = [self favoriteItem];
    [favoriteItem setBadge:badge];
    return;
}

- (void)setCommentBadge:(NSString *)badge {
    FMItemDetailBottomItemView *commentItem = [self commentItem];
    [commentItem setBadge:badge];
    return;
}

- (void)setBuyAction:(void (^)(void))block {
    _buyActionBlock = block;
}

- (void)setShareAction:(void (^)(void))block {
    _shareActionBlock = block;
}

- (void)setEditAction:(void (^)(void))block {
    _editActionBlock = block;
}

- (void)setOperationAction:(void (^)(void))block {
    _operationActionBlock = block;
}

- (void)favoriteAction {
    FMItemDetailBottomItemView *favoriteItem = (FMItemDetailBottomItemView *) [self viewWithTag:kFavoriteItemTag];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$itemDetailFavoriteAction:item:), favoriteItem);
}

- (void)commentAction {
    FMItemDetailBottomItemView *commentItem = (FMItemDetailBottomItemView *) [self viewWithTag:kCommentItemTag];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$itemDetailCommentAction:item:), commentItem);
}

- (void)setItems:(NSArray *)items {
    if (!items || [items count] == 0) {
        return;
    }

    for (NSUInteger i = 0; i < [items count]; i++) {
        FMItemDetailBottomItemView *itemView = [items objectAtIndex:i];
        itemView.backgroundColor = [UIColor clearColor];
        itemView.frame = CGRectMake(80 * i, 3, 80, 44);
        [self addSubview:itemView];
    }
}

- (UIImage *)_getBottomBgImage {
    return [UIImage imageWithFileName:@"item_detail_bottom_bar.png"];
}

- (BOOL)isSeller {
    return [[FMApplication instance].loginUser isMyself:_itemDO.userId];
}

@end