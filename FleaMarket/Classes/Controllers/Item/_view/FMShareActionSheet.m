// 
// Created by henson on 12/26/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import <TBSocialShareSDK/TBSocialShareManager.h>
#import "FMShareActionSheet.h"
#import "TBMBBind.h"
#import "UIImage+Helper.h"

@implementation FMShareActionSheetItem {
    UILabel *_textLabel;
    UIButton *_iconButton;
    UIImage *_image;

@private
    __weak id _delegate;
}

@synthesize textLabel = _textLabel;
@synthesize image = _image;
@synthesize delegate = _delegate;

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 60, 80)];
    if (self) {
        CGRect iconRect = {{1,0},{58,59}};
        _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconButton.frame = iconRect;
        [_iconButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_iconButton];

        CGRect textRect = {{0,60},{60,25}};
        _textLabel = [[UILabel alloc] initWithFrame:textRect];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = FMColorWithRed(117, 117, 117);
        _textLabel.font = [UIFont systemFontOfSize:14.f];
        [self addSubview:_textLabel];
    }

    return self;
}

- (void)buttonClick:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetDidClick:)]) {
        [_delegate actionSheetDidClick:self];
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [_iconButton setImage:image forState:UIControlStateNormal];
}

- (void)setLoginImage:(UIImage *)loginImage {
    _loginImage = loginImage;
    if (_isLogin) {
        [_iconButton setImage:loginImage forState:UIControlStateNormal];
    }
}

@end

@implementation FMShareActionSheet {
    NSMutableArray *_items;
    void (^_clickedItemBlock)(FMShareActionSheetItem *, FMShareActionSheet *);

    UIView *_bgView;
    UIView *_shareView;
}

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];

        __weak FMShareActionSheet *weakSelf = self;
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [weakSelf selfDismiss];
        };
        [self addSubview:_bgView];

        _shareView = [[UIView alloc] init];
        _shareView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_shareView];
        [self setupItems];
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:
                CGRectMake(16, 130, FM_SCREEN_WIDTH - 32, 36)];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setBackgroundImage:[[UIImage imageNamed:@"share_btn.png"]
                resizeImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]
                                forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:FMColorWithRed(117, 117, 117) forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        cancelButton.titleLabel.font = FMFont(YES, 14);
        [cancelButton addTarget:self action:@selector(selfDismiss) forControlEvents:UIControlEventTouchUpInside];
        [_shareView addSubview:cancelButton];
    }
    return self;
}

- (void)selfDismiss {
    [UIView animateWithDuration:0.4
                     animations:^{
                         _shareView.frame = CGRectMake(0, self.superview.frame.size.height,
                                 self.superview.frame.size.width, 200);
                         _bgView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)setClickItemAction:(void (^)(FMShareActionSheetItem *, FMShareActionSheet *))block {
    _clickedItemBlock = block;
}

-(void)showInView:(UIView *)view {
    self.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    _bgView.frame = self.frame;
    [view addSubview:self];
    _shareView.frame = CGRectMake(0, view.frame.size.height,
            view.frame.size.width, 200);
    _bgView.alpha = 0.0;
    [UIView animateWithDuration:0.4
                     animations:^{
                         _shareView.frame = CGRectMake(0, view.frame.size.height - 200,
                                 view.frame.size.width, 200);
                         _bgView.alpha = 0.7;
                     }];
}

- (void)setupItems {
    FMShareActionSheetItem *weChatItem = [[FMShareActionSheetItem alloc] init];
    weChatItem.isLogin = [[TBSocialShareManager instance] isWXAppInstalled];
    weChatItem.textLabel.text = @"微信";
    weChatItem.image = [UIImage imageNamed:@"share_weixin_icon.png"];
    weChatItem.loginImage = [UIImage imageNamed:@"share_weixin_icon_login.png"];
    weChatItem.type = kFMShareTypeWeiXin;

    FMShareActionSheetItem *weChatFriendItem = [[FMShareActionSheetItem alloc] init];
    weChatFriendItem.isLogin = [[TBSocialShareManager instance] isWXAppInstalled];
    weChatFriendItem.textLabel.text = @"朋友圈";
    weChatFriendItem.image = [UIImage imageNamed:@"share_weixin_friend_icon.png"];
    weChatFriendItem.loginImage = [UIImage imageNamed:@"share_weixin_friend_icon_login.png"];
    weChatFriendItem.type = kFMShareTypeWeiXinFriend;

    FMShareActionSheetItem *weiboItem = [[FMShareActionSheetItem alloc] init];
    weiboItem.isLogin = [[TBSocialShareManager instance] isLoginWithShareType:TBSocialShareTypeSina];
    weiboItem.textLabel.text = @"微博";
    weiboItem.image = [UIImage imageNamed:@"share_weibo_icon.png"];
    weiboItem.loginImage = [UIImage imageNamed:@"share_weibo_icon_login.png"];
    weiboItem.type = kFMShareTypeWeibo;

    FMShareActionSheetItem *doubanItem = [[FMShareActionSheetItem alloc] init];
    doubanItem.isLogin = [[TBSocialShareManager instance] isLoginWithShareType:TBSocialShareTypeDouban];
    doubanItem.textLabel.text = @"豆瓣";
    doubanItem.image = [UIImage imageNamed:@"share_douban_icon.png"];
    doubanItem.loginImage = [UIImage imageNamed:@"share_douban_icon_login.png"];
    doubanItem.type = kFMShareTypeDouban;

    _items = [NSMutableArray arrayWithObjects:weChatItem,
                                              weChatFriendItem,
                                              weiboItem,
                                              doubanItem,
                                              nil];

    for (NSUInteger i=0; i<_items.count; i++) {
        FMShareActionSheetItem *item = [_items objectAtIndex:i];
        item.backgroundColor = [UIColor clearColor];
        if (i < 4) {
            item.frame = CGRectMake(16 + 76*i, 35, 60, 85);
        } else {
            item.frame = CGRectMake(16 + 76*(i-4), 35 + 100, 60, 85);
        }
        item.tag = i;
        TBMBAutoNilDelegate(FMShareActionSheetItem *, item, delegate, self);
        [_shareView addSubview:item];
    }
}

- (void)actionSheetDidClick:(FMShareActionSheetItem *)actionSheetItem {
    if (_clickedItemBlock) {
        _clickedItemBlock(actionSheetItem, self);
    }
    [self selfDismiss];
}

@end