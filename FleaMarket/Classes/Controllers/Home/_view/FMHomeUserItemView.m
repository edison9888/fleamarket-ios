// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import "FMHomeUserItemView.h"
#import "UIImage+Helper.h"
#import "FMHomeItemDO.h"
#import "UIImageView+WebCache.h"
#import "FMImageView.h"
#import "FMHomeScrollImageView.h"
#import "NSString+Helper.h"

#define kUserAvatarWidth  (35)
#define kUserAvatarHeight (35)
#define kUserAvatarGap    (8)

@implementation FMHomeUserItemView {
    __weak FMHomeScrollImageView *_imageView;
    __weak FMImageView *_shadowImageView;
    __weak FMImageView *_userImageViw;
    __weak UILabel *_userTextLabel;
    __weak FMImageView *_userStarImageView;

    FMHomeItemDO *_item;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;

        FMHomeScrollImageView *imageView = [[FMHomeScrollImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        _imageView = imageView;

        UIImage *shadowImage = [UIImage imageWithFileName:@"home_item_shadow_big.png"];
        FMImageView *shadowImageView = [[FMImageView alloc] initWithFrame:CGRectZero];
        shadowImageView.image = shadowImage;
        [self addSubview:shadowImageView];
        _shadowImageView = shadowImageView;

        FMImageView *userImageViw = [[FMImageView alloc] initWithFrame:CGRectZero];
        userImageViw.backgroundColor = [UIColor clearColor];
        userImageViw.layer.borderWidth = 1.5;
        userImageViw.layer.borderColor = [[UIColor whiteColor] CGColor];
        userImageViw.layer.cornerRadius = kUserAvatarWidth / 2.f;
        userImageViw.layer.masksToBounds = YES;
        [self addSubview:userImageViw];
        _userImageViw = userImageViw;

        UILabel *userTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        userTextLabel.backgroundColor = [UIColor clearColor];
        userTextLabel.textColor = [UIColor whiteColor];
        userTextLabel.textAlignment = NSTextAlignmentLeft;
        userTextLabel.font = FMFont(YES, 15);
        userTextLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:userTextLabel];
        _userTextLabel = userTextLabel;

        FMImageView *starImage = [[FMImageView alloc] initWithFrame:CGRectZero];
        starImage.backgroundColor = [UIColor clearColor];
        [self addSubview:starImage];
        _userStarImageView = starImage;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _shadowImageView.frame = self.bounds;

    CGRect userRect = {{kUserAvatarGap, self.frame.size.height - kUserAvatarGap - kUserAvatarHeight}, {kUserAvatarWidth, kUserAvatarHeight}};
    _userImageViw.frame = userRect;

    CGRect userTextRect = {{userRect.origin.x + userRect.size.width + 5, userRect.origin.y + 10}, {145, 16}};
    _userTextLabel.frame = userTextRect;

    CGRect starRect = {{userTextRect.origin.x - 15, userTextRect.origin.y + userTextRect.size.height - 5}, {14, 14}};
    _userStarImageView.frame = starRect;
}

- (FMHomeItemDO *)homeItemDO {
    return _item;
}

- (void)setHomeItemDO:(FMHomeItemDO *)itemDO {
    _item = itemDO;
    _imageView.frame = self.bounds;
    [_imageView setData:itemDO.picUrls
               isSquare:YES
         imageScaleType:FMImageScale320x320];

    NSString *headPicUrl = itemDO.seller.sellerHeadUrl;
    [_userImageViw setImageWithURL:[NSURL URLWithString:headPicUrl]
                  placeholderImage:nil
                         completed:nil];

    _userTextLabel.text = [NSString stringWithFormat:@"%@",
                                                     itemDO.seller.seller];

    BOOL b = [itemDO.seller.typeUrl isNotBlank];
    _userStarImageView.hidden = !b;
    if (b) {
        [_userStarImageView setFMImageWithURL:itemDO.seller.typeUrl
                               imageScaleType:FMImageScaleNone
                                      success:^(UIImage *image, FMImageView *view) {
                                          view.frame = CGRectMake(
                                                  view.frame.origin.x,
                                                  view.frame.origin.y,
                                                  image.size.width / 2,
                                                  image.size.height / 2);
                                      }
                                      failure:^(NSError *error, FMImageView *view) {

                                      }];
    } else {
        [_userStarImageView setFMImageWithURL:nil];
    }

}

@end