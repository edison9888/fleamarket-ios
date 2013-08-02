// 
// Created by henson on 7/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemShareTextView.h"
#import "FMImageView.h"
#import "FMItemDO.h"

#define kItemDetailWeiboShareText @"我在@淘宝网跳蚤街 iPhone客户端上看一个有意思的宝贝'%@'，只卖￥%@元，挺不错的，大家赶紧来瞧瞧%@ ,下载客户端淘更多超值宝贝 %@"
#define kItemDetailDoubanShareText @"我在淘宝二手上看到一个宝贝蛮有意思的 '%@'，只卖￥%@元，挺不错的，大家赶紧来瞧瞧%@ ,下载客户端淘更多超值宝贝 %@"

@interface FMItemShareTextView () <UITextViewDelegate>

@end

@implementation FMItemShareTextView {
    UITextView *_textView;
    FMImageView *_itemImageView;
    UILabel *_wordsCountLabel;
    FMItemDO *_itemDO;
    UILabel *_titleLabel;
    void (^_shareWeiboActionBlock)(UITextView *, FMItemShareTextView *view);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgRect = {{5,5},{310,195}};
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:bgRect];
        bgImageView.backgroundColor = [UIColor clearColor];
        bgImageView.userInteractionEnabled = YES;
        bgImageView.image = [[UIImage imageNamed:@"item_weibo_share_bg.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
        [self addSubview:bgImageView];

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 40, 40);
        closeButton.backgroundColor = [UIColor clearColor];
        [closeButton setImage:[UIImage imageNamed:@"item_share_close_icon.png"]
                     forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction:)
              forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:closeButton];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 150, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = FMColorWithRed(0x22, 0x22, 0x22);
        titleLabel.font = FMFont(NO, 16.0f);
        [bgImageView addSubview:titleLabel];
        _titleLabel = titleLabel;

        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(320 - 17.5 - 47.5, 5, 47.5, 30);
        [shareButton setBackgroundImage:[[UIImage imageNamed:@"item_weibo_share_send_bg.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]
                               forState:UIControlStateNormal];
        [shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [shareButton setTitleColor:FMColorWithRed(0x8F, 0x76, 0x56) forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        shareButton.titleLabel.font = FMFont(YES, 14.0f);
        [shareButton addTarget:self
                        action:@selector(shareAction:)
              forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:shareButton];

        CGRect textViewRect = {{0,40},{230,140}};
        _textView = [[UITextView alloc] initWithFrame:textViewRect];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = FMColorWithRed(0x8F, 0x76, 0x56);
        _textView.font = FMFont(YES, 14.0f);
        _textView.showsVerticalScrollIndicator = NO;
        [bgImageView addSubview:_textView];

        CGRect itemImageBgRect = {{235,50},{67,67}};
        UIImageView *itemImageBgView = [[UIImageView alloc] initWithFrame:itemImageBgRect];
        itemImageBgView.backgroundColor = [UIColor clearColor];
        itemImageBgView.image = [UIImage imageNamed:@"item_weibo_share_image_bg.png"];
        [bgImageView addSubview:itemImageBgView];

        _itemImageView = [[FMImageView alloc] initWithFrame:CGRectMake(3, 3, 61, 61)];
        _itemImageView.backgroundColor = [UIColor clearColor];
        [itemImageBgView addSubview:_itemImageView];

        _wordsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 163, 45, 15)];
        _wordsCountLabel.backgroundColor = [UIColor clearColor];
        _wordsCountLabel.textAlignment = NSTextAlignmentRight;
        _wordsCountLabel.font = [UIFont fontWithName:@"Georgia-BoldItalic" size:14.f];
        _wordsCountLabel.textColor = FMColorWithRed(0x22, 0x22, 0x22);
        _wordsCountLabel.text = [NSString stringWithFormat:@"%d", 140];
        [bgImageView addSubview:_wordsCountLabel];

        [_textView becomeFirstResponder];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewTextDidChangeNotification)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];

        self.type = kShareTypeWeibo;
    }

    return self;
}

- (void)setFocus {
    [_textView becomeFirstResponder];
}

- (void)setType:(kShareType)type {
    _type = type;

    if (_type == kShareTypeWeibo) {
        _titleLabel.text = @"新浪微博";
        return;
    }
    _titleLabel.text = @"豆瓣";
    return;
}

- (void)shareWeiboAction:(void (^)(UITextView *, FMItemShareTextView *view))block {
    _shareWeiboActionBlock = block;
}

- (void)shareAction:(UIButton *)button {
    int length = [self weiboShareTextLength];
    if (length > 140) {
        [FMCommon alert:@"" message:@"亲，您的分享内容太多了"];
        return;
    }
    if (_shareWeiboActionBlock) {
        _shareWeiboActionBlock(_textView,self);
    }
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;
    NSString *content = self.type == kShareTypeWeibo ? kItemDetailWeiboShareText : kItemDetailDoubanShareText;
    NSString *priceString = [NSString stringWithFormat:@"%.2f", [_itemDO.price doubleValue]];
    _textView.text = [NSString stringWithFormat:content,_itemDO.title,priceString,_itemDO.shortUrl,
                                                APP_STORE_DOWNLOAD_URL];
    [_itemImageView setFMImageWithURL:_itemDO.picUrl
                       imageScaleType:FMImageScale160x160];

}

- (void)closeAction:(UIButton *)button {
    [self closeShareView];
}

- (void)closeShareView {
    [_textView resignFirstResponder];
    [self removeFromSuperview];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self wordsCountChanged];
    return YES;
}

- (void)textViewTextDidChangeNotification {
    [self wordsCountChanged];
}

- (void)wordsCountChanged {
    int length = [self weiboShareTextLength];
    if (140 - length >= 0) {
        NSString *words = [NSString stringWithFormat:@"%d", 140 - length];
        _wordsCountLabel.text = words;
        _wordsCountLabel.textColor = [UIColor grayColor];
        return;;
    }
    NSInteger c = length - 140;
    _wordsCountLabel.text = [NSString stringWithFormat:@"-%d", c > 99 ? 99 : c];
    _wordsCountLabel.textColor = [UIColor redColor];
    return;
}

- (int)weiboShareTextLength {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *shareContent = _textView.text;
    return (int) ceill([shareContent lengthOfBytesUsingEncoding:enc] / 2.f);
}

- (void)dealloc {
    NSLog(@"dealloc %@", [self description]);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}


@end