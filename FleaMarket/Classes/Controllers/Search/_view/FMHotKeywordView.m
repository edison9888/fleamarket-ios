//
// Created by yuanxiao on 13-6-20.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMHotKeywordView.h"
#import "NSString+Helper.h"
#import "FMStyle.h"
#import "UIImage+Helper.h"

#define kHotKeywordLeftWidth         10
#define kHotKeywordButtonLeftWidth   15
#define kHotKeywordButtonTopHeight   10

@implementation FMHotKeywordView {
@private
    NSArray *_hotKeyword;

    void (^_touchKeyword)(NSString *);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UILabel *hotTitle = [[UILabel alloc] initWithFrame:CGRectMake(kHotKeywordLeftWidth, kHotKeywordLeftWidth, 100, 20)];
        hotTitle.backgroundColor = [UIColor clearColor];
        hotTitle.textColor = [FMColor instance].cellColor;
        hotTitle.font = [FMFontSize instance].cellLabelSize;
        hotTitle.text = @"热门关键词";
        [self addSubview:hotTitle];
    }
    return self;
}

- (void)setHotKeyword:(NSArray *)hotArray {
    _hotKeyword = [NSArray arrayWithArray:hotArray];
    CGFloat left = kHotKeywordLeftWidth;
    CGFloat top = kHotKeywordLeftWidth + 30;
    UIImage *imageBG = [UIImage createImageWithColor:FMColorWithRed(235, 235, 235)];
    for (NSUInteger i = 0; i < hotArray.count; i++) {
        NSString *keyword = [hotArray objectAtIndex:i];
        CGSize size = [keyword sizeWithFont:FMFont(NO, 12) constrainedToSize:CGSizeMake(300, 20)];
        CGRect rect = CGRectMake(
                left,
                top,
                kHotKeywordButtonLeftWidth * 2 + size.width,
                kHotKeywordButtonTopHeight * 2 + size.height);
        if (rect.origin.x + rect.size.width > FM_SCREEN_WIDTH - 20) {
            left = kHotKeywordLeftWidth;
            top += rect.size.height + 5;

            rect.origin.x = left;
            rect.origin.y = top;
        }
        left += rect.size.width + 5;
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        [button setBackgroundImage:imageBG forState:UIControlStateNormal];
        [button setTitleColor:[FMColor instance].cellColor forState:UIControlStateNormal];
        [button setTitle:keyword forState:UIControlStateNormal];
        button.titleLabel.font = FMFont(NO, 14);
        [button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self addSubview:button];
    }
    CGRect rect = self.frame;
    rect.size.height = top + 55;
    self.frame = rect;
}

- (void)touchButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUInteger i = (NSUInteger)button.tag;
    if (i < _hotKeyword.count) {
        NSString *keyword = [_hotKeyword objectAtIndex:i];
        if (![keyword isBlank] && _touchKeyword) {
            _touchKeyword(keyword);
        }
    }
}

- (void)setTouchKeyword:(void (^)(NSString *keyword))block {
    _touchKeyword = block;
}

@end