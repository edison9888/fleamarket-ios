// 
// Created by henson on 6/18/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMThemeItemCell.h"
#import "FMAvatarImageView.h"
#import "FMThemeDO.h"
#import "FMCommon.h"

#define kAvatarViewHeight (20)
#define kAvatarViewWidth  (20)
#define kViewGap          (8)

@implementation FMThemeItemCell {
    UIView *_containerView;
    FMImageView *_bannerImageView;
    FMAvatarImageView *_avatarImageView;
    UILabel *_userLabel;
    UIButton *_postTimeView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(kViewGap, 10, 320 - 16, 276 / 2.f)];
        containerView.backgroundColor = FMColorWithRed(243, 243, 243);
        [self.contentView addSubview:containerView];
        _containerView = containerView;

        CGRect bannerRect = {{0,0}, {FM_SCREEN_WIDTH - 16, 109}};
        FMImageView *bannerImageView = [[FMImageView alloc] initWithFrame:bannerRect];
        [_containerView addSubview:bannerImageView];
        _bannerImageView = bannerImageView;

        CGRect avatarRect = {{10, bannerRect.size.height + 4}, {kAvatarViewWidth, kAvatarViewHeight}};
        FMAvatarImageView *avatarImageView = [[FMAvatarImageView alloc] initWithFrame:avatarRect];
        avatarImageView.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:avatarImageView];
        _avatarImageView = avatarImageView;

        CGRect userRect = {{avatarRect.origin.x + avatarRect.size.width + 5, bannerRect.size.height + 7.5}, {100, 15}};
        UILabel *userLabel = [[UILabel alloc] initWithFrame:userRect];
        userLabel.backgroundColor = [UIColor clearColor];
        userLabel.textColor = FMColorWithRed(85, 85, 85);
        userLabel.font = FMFont(YES, 12);
        [_containerView addSubview:userLabel];
        _userLabel = userLabel;

        UIButton *postTimeView = [UIButton buttonWithType:UIButtonTypeCustom];
        [postTimeView setImage:[UIImage imageNamed:@"post_time_icon.png"] forState:UIControlStateNormal];
        [postTimeView setImage:[UIImage imageNamed:@"post_time_icon.png"] forState:UIControlStateHighlighted];
        postTimeView.titleLabel.font = FMFont(NO, 12);
        [postTimeView setTitleColor:FMColorWithRed(126, 125, 126) forState:UIControlStateNormal];
        [postTimeView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        postTimeView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_containerView addSubview:postTimeView];
        _postTimeView = postTimeView;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

+ (float)cellHeight:(FMThemeDO *)themeDO {
    return 10 + 10 + 276 / 2.f;
}

- (void)setThemeDO:(FMThemeDO *)themeDO serverTime:(NSString *)serverTime {
    [_bannerImageView setFMImageWithURL:themeDO.picUrl
                         imageScaleType:FMImageScaleNone
                       placeholderImage:nil];

    [_avatarImageView setFMImageWithURL:themeDO.headPicUrl
                         imageScaleType:FMImageScale60x60
                       placeholderImage:nil];

    _userLabel.text = themeDO.nick;

    NSString *postTime = [FMCommon relativeTime:themeDO.gmtCreate serverTime:serverTime];
    NSString *str = [NSString stringWithFormat:@"%@  来自%@", postTime, themeDO.from];
    CGSize strSize = [str sizeWithFont:_postTimeView.titleLabel.font
                     constrainedToSize:CGSizeMake(1000, 15)
                         lineBreakMode:NSLineBreakByWordWrapping];
    [_postTimeView setTitle:str forState:UIControlStateNormal];

    CGRect postTimeRect = CGRectMake(_containerView.frame.size.width - 10 - strSize.width - 15,
            _bannerImageView.frame.size.height + 7.5, strSize.width + 15, 15);
    _postTimeView.frame = postTimeRect;
}

@end