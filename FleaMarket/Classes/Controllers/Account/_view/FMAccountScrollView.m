//
// Created by yuanxiao on 13-6-27.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import "FMAccountScrollView.h"
#import "UIImage+Helper.h"
#import "FMAccountViewController.h"
#import "TBMBGlobalFacade.h"

#define kAccountItemLabelStartX  0
#define kAccountItemLabelStartY  11
#define kAccountItemStartY       3
#define kAccountItemStartX       4
#define kAccountItemWidth        69
#define kAccountItemHeight       49


@implementation FMAccountScrollItemView {
@private
    UILabel *_titleLabel;
    UILabel *_countLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundImage:[UIImage imageWithFileName:@"btn_account.png"]
                        forState:UIControlStateNormal];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                kAccountItemLabelStartX,
                kAccountItemLabelStartY,
                self.frame.size.width,
                (self.frame.size.height - kAccountItemLabelStartY * 2)/2)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FMFont(YES, 12);
        [self addSubview:_titleLabel];

        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                kAccountItemLabelStartX,
                kAccountItemLabelStartY + _titleLabel.frame.size.height + 5,
                self.frame.size.width,
                (self.frame.size.height - kAccountItemLabelStartY * 2)/2)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = FMFont(NO, 12);
        _countLabel.textColor = FMColorWithRGB0X(0xa39a80);
        [self addSubview:_countLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
    if ([title isEqualToString:@"消息中心"]) {
        _countLabel.textColor = FMColorWithRed(0xff, 0x59, 0x18);
    }
}

- (void)setCount:(NSInteger)count {
    _countLabel.text = [NSString stringWithFormat:@"%d", count];
    if ([_titleLabel.text isEqualToString:@"消息中心"]) {
        _countLabel.textColor = count > 0 ? FMColorWithRed(0xff, 0x59, 0x18) : FMColorWithRGB0X(0xa39a80);
    }
}

@end

@implementation FMAccountScrollView {
@private
    FMAccountInfo *_accountInfo;

    UIScrollView *_scrollView;
}

@synthesize accountInfo = _accountInfo;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = FMColorWithRed(0xf3, 0xf3, 0xf3);

        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];

        [self initView];

        _scrollView.contentSize = CGSizeMake((kAccountItemStartX + kAccountItemWidth) * 5 + kAccountItemStartX,
                self.frame.size.height);

        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        topLine.backgroundColor = FMColorWithRed(0xdb, 0xdb, 0xdb);
        [self addSubview:topLine];

        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        bottomLine.backgroundColor = FMColorWithRed(0xdb, 0xdb, 0xdb);
        [self addSubview:bottomLine];
    }
    return self;
}

- (void)initView {
    CGFloat start = kAccountItemStartX + kAccountItemWidth;
    CGRect rect = CGRectMake(kAccountItemStartX, kAccountItemStartY, kAccountItemWidth, kAccountItemHeight);
    FMAccountScrollItemView *soldItemView = [[FMAccountScrollItemView alloc] initWithFrame:rect];
    [soldItemView setTitle:@"已售出"];
    [_scrollView addSubview:soldItemView];
    TBMBBindObjectWeak(tbKeyPath(self, accountInfo.soldCount), soldItemView, ^(FMAccountScrollItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [soldItemView addTarget:self action:@selector(touchSoldItemView:) forControlEvents:UIControlEventTouchUpInside];

    rect = CGRectMake(start * 1 + kAccountItemStartX, kAccountItemStartY, kAccountItemWidth, kAccountItemHeight);
    FMAccountScrollItemView *boughtItemView = [[FMAccountScrollItemView alloc] initWithFrame:rect];
    [boughtItemView setTitle:@"已买到"];
    [_scrollView addSubview:boughtItemView];
    TBMBBindObjectWeak(tbKeyPath(self, accountInfo.boughtCount), boughtItemView, ^(FMAccountScrollItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [boughtItemView addTarget:self action:@selector(touchBoughtItemView:) forControlEvents:UIControlEventTouchUpInside];

    rect = CGRectMake(start * 2 + kAccountItemStartX, kAccountItemStartY, kAccountItemWidth, kAccountItemHeight);
    FMAccountScrollItemView *messageUnreadItemView = [[FMAccountScrollItemView alloc] initWithFrame:rect];
    [messageUnreadItemView setTitle:@"消息中心"];
    [_scrollView addSubview:messageUnreadItemView];
    TBMBBindObjectWeak(tbKeyPath(self, accountInfo.messageUnreadCount), messageUnreadItemView, ^(FMAccountScrollItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [messageUnreadItemView addTarget:self action:@selector(messageSoldItemView:) forControlEvents:UIControlEventTouchUpInside];

    rect = CGRectMake(start * 3 + kAccountItemStartX, kAccountItemStartY, kAccountItemWidth, kAccountItemHeight);
    FMAccountScrollItemView *collectItemView = [[FMAccountScrollItemView alloc] initWithFrame:rect];
    [collectItemView setTitle:@"我的收藏"];
    [_scrollView addSubview:collectItemView];
    TBMBBindObjectWeak(tbKeyPath(self, accountInfo.collectCount), collectItemView, ^(FMAccountScrollItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [collectItemView addTarget:self action:@selector(touchCollectItemView:) forControlEvents:UIControlEventTouchUpInside];

    rect = CGRectMake(start * 4 + kAccountItemStartX, kAccountItemStartY, kAccountItemWidth, kAccountItemHeight);
    FMAccountScrollItemView *postQueueItemView = [[FMAccountScrollItemView alloc] initWithFrame:rect];
    [postQueueItemView setTitle:@"发布队列"];
    [_scrollView addSubview:postQueueItemView];
    TBMBBindObjectWeak(tbKeyPath(self, accountInfo.postQueueCount), postQueueItemView, ^(FMAccountScrollItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [postQueueItemView addTarget:self action:@selector(touchPostQueueItemView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchSoldItemView:(id)sender {
    TBMBGlobalSendNotificationForSEL(@selector($$pushToMySoldViewController));
}

- (void)touchBoughtItemView:(id)sender {
    TBMBGlobalSendNotificationForSEL(@selector($$pushToMyBoughtViewController));
}

- (void)touchCollectItemView:(id)sender {
    TBMBGlobalSendNotificationForSEL(@selector($$pushFavViewController));
}

- (void)touchPostQueueItemView:(id)sender {
    TBMBGlobalSendNotificationForSEL(@selector($$pushPostQueueViewController));
}

- (void)messageSoldItemView:(id)sender {
    TBMBGlobalSendNotificationForSEL(@selector($$pushMessageViewController));
}

@end