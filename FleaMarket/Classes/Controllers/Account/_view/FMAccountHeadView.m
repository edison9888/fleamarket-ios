//
// Created by yuanxiao on 13-6-27.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMAccountHeadView.h"
#import "FMImageView.h"
#import "FMAvatarImageView.h"
#import "FMAccountViewController.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "TBMBBind.h"


@implementation FMAccountHeadView {
@private
    FMAvatarImageView *_imageView;
    UILabel *_userNick;
    FMAccountInfo *_accountInfo;
}

@synthesize accountInfo = _accountInfo;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bgImageView.image = [UIImage imageWithFileName:@"bg_account_head.png"];
        [self addSubview:bgImageView];

        _imageView = [[FMAvatarImageView alloc] initWithFrame:
                CGRectMake((self.frame.size.width - 60) / 2, 12, 60, 60)];
        _imageView.isClick = NO;
        [self addSubview:_imageView];
        TBMBBindObjectWeak(tbKeyPath([FMApplication instance], loginUser.id), _imageView, ^(FMAvatarImageView *host, id old, id new) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [host setFMImageWithURL:[NSString stringWithFormat:kApiHeadPortrait, new]];
            });
        }
        );

        _userNick = [[UILabel alloc] initWithFrame:
                CGRectMake(0, 12 + 60 + 5, self.frame.size.width, 20)];
        _userNick.textAlignment = NSTextAlignmentCenter;
        _userNick.font = FMFont(YES, 14);
        _userNick.backgroundColor = [UIColor clearColor];
        _userNick.textColor = [UIColor whiteColor];
        [self addSubview:_userNick];
        TBMBBindObjectWeak(tbKeyPath([FMApplication instance], loginUser.name), _userNick, ^(UILabel *host, id old, id new) {
            dispatch_async(dispatch_get_main_queue(), ^{
                host.text = new;
            });
        }
        );
    }
    return self;
}


@end