//
// Created by yuanxiao on 13-7-12.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBBind.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMSellerTitleView.h"
#import "UIImage+Helper.h"
#import "FMAccountViewController.h"
#import "FMItemDO.h"
#import "FMAvatarImageView.h"
#import "FMUser.h"
#import "FMApplication.h"
#import "FMUserService.h"

#define kSellerRankHeight  12

@implementation FMSellerTitleView {

@private
    FMItemDOList *_listDO;
    FMItemDO *_itemDO;
    FMAccountInfo *_accountInfo;
    UILabel *_sellCount;
    UILabel *_userName;

    FMImageView *_rankImageView;
}

@synthesize listDO = _listDO;
@synthesize itemDO = _itemDO;
@synthesize accountInfo = _accountInfo;

- (id)initWithFrame:(CGRect)frame withItemDO:(FMItemDO *)itemDO {
    self = [super initWithFrame:frame];
    if (self) {
        _itemDO = itemDO;

        FMAvatarImageView *avatarImageView = [[FMAvatarImageView alloc]
                initWithFrame:CGRectMake(10, 10, 40, 40)];
        avatarImageView.isClick = NO;
        avatarImageView.layer.borderWidth = 0.5;
        avatarImageView.layer.borderColor = [UIColor grayColor].CGColor;
        NSString *url;
        if (itemDO.id) {
            url = [NSString stringWithFormat:kApiHeadPortrait, itemDO.userId];
        } else {
            url = itemDO.userId;
        }
        [avatarImageView setFMImageWithURL:url];
        [self addSubview:avatarImageView];

        _userName = [[UILabel alloc] init];
        _userName.backgroundColor = [UIColor clearColor];
        _userName.font = FMFont(YES, 14);
        _userName.text = itemDO.userNick;
        [self addSubview:_userName];
        CGSize size = [_userName.text sizeWithFont:_userName.font
                                 constrainedToSize:CGSizeMake(200, 20)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        _userName.frame = CGRectMake(60, 10, size.width, 20);

        _sellCount = [[UILabel alloc] init];
        _sellCount.backgroundColor = [UIColor clearColor];
        _sellCount.font = FMFont(NO, 14);
        [self addSubview:_sellCount];

        _rankImageView = [[FMImageView alloc] init];
        __weak FMImageView *rankImageView = _rankImageView;
        TBMBBindObjectWeak(tbKeyPath(self, listDO.totalCount), _sellCount, ^(UILabel *host, id old, id new) {
            NSInteger count = [new intValue];
            if (count > 0) {
                host.text = [NSString stringWithFormat:@"%d件在售宝贝", count];
                CGSize _size = [host.text sizeWithFont:host.font
                                     constrainedToSize:CGSizeMake(200, 20)
                                         lineBreakMode:NSLineBreakByWordWrapping];
                host.frame = CGRectMake(60, 30, _size.width, 20);
                rankImageView.frame = CGRectMake(60 + _size.width + 5, 34,
                        rankImageView.frame.size.width, kSellerRankHeight);
            }
        }
        );
        UIButton *sellerWW = [[UIButton alloc] initWithFrame:
                CGRectMake(0, 60, self.frame.size.width, 34)];
        [sellerWW setTitle:@"联系卖家" forState:UIControlStateNormal];
        [sellerWW setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sellerWW.titleLabel.font = FMFont(NO, 14);
        [sellerWW setImage:[UIImage imageWithFileName:@"btn_wangwang@2x.png"] forState:UIControlStateNormal];
        [sellerWW setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [sellerWW setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        sellerWW.layer.borderWidth = 1;
        sellerWW.layer.borderColor = FMColorWithRed(216, 214, 198).CGColor;
        [self addSubview:sellerWW];
        [sellerWW addTarget:self action:@selector(touchWW:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)touchWW:(id)sender {
    FMUser *user = [FMApplication instance].loginUser;
    if (user.isLogin && [user.id isEqualToString:_itemDO.userId]) {
        [FMCommon showToast:self.superview.superview text:@"亲，自己不能和自己聊天哦~"];
        return;
    }
    TBMBGlobalSendNotificationForSEL(@selector($$toWangWang:));
}

- (void)setFlagArray:(NSArray *)flagArray {
    if (flagArray.count == 0) {
        return;
    }
    CGRect rect = CGRectMake(41, 35, 16, 16);
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 8;
    bgView.layer.borderWidth = 0.5;
    bgView.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:bgView];

    rect = CGRectMake(2, 2, 12, 12);
    NSString *url = [flagArray objectAtIndex:0];
    FMImageView *imageView = [[FMImageView alloc] initWithFrame:rect];
    [imageView setFMImageWithURL:url];
    [bgView addSubview:imageView];
}

- (void)setSellerVip:(id)data {
    data = [[data objectForKey:@"user_get_response"] objectForKey:@"user"];
    NSString *vip_info = [data objectForKey:@"vip_info"];
    if (![vip_info isEqualToString:@"asso_vip"]) {
        CGRect rect = CGRectMake(_userName.frame.origin.x + _userName.frame.size.width + 5, 12, 13, 13);
        NSString *vip_info_url = [NSString stringWithFormat:@"icon_%@", vip_info];
        UIImageView *vipImageView = [[UIImageView alloc] initWithFrame:rect];
        vipImageView.image = [UIImage imageNamed:vip_info_url];
        [self addSubview:vipImageView];
    }

    NSString *url = [FMUserService getUserRate:[[[data objectForKey:@"buyer_credit"] objectForKey:@"score"] integerValue]
                                       isBuyer:YES];

    [_rankImageView setFMImageWithURL:url
                       imageScaleType:FMImageScaleNone
                              success:^(UIImage *image, FMImageView *view) {
                                  CGRect rect = view.frame;
                                  rect.size.width = image.size.width * kSellerRankHeight / image.size.height;
                                  view.frame = rect;
                              }
                              failure:nil];
    [self addSubview:_rankImageView];
}

@end