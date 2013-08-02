//
// Created by yuanxiao on 13-7-12.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "FMListCollectView.h"
#import "FMItemDO.h"
#import "UIImage+Helper.h"


@implementation FMListCollectView {
@private
    void (^_clickCollect)();

    UIImageView *_collectImageView;
    UILabel *_collectCount;

    BOOL _isClick;

    BOOL _isStartCollect;
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.6;
        self.layer.cornerRadius = 13;

        _collectImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake(10, 5.5, [self starImage].size.width, [self starImage].size.height)];
        [self addSubview:_collectImageView];

        _collectCount = [[UILabel alloc] init];
        _collectCount.textColor = [UIColor whiteColor];
        _collectCount.backgroundColor = [UIColor clearColor];
        _collectCount.font = FMFont(NO, 12);
        [self addSubview:_collectCount];

        [self addTarget:self action:@selector(touchView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setItemDO:(FMItemDO *)itemDO listType:(FMListType)listType {
    _isStartCollect = NO;
    if (itemDO.subscribed) {
        _collectImageView.image = [self starHighlightImage];
        if (_isClick) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _collectImageView.frame = CGRectMake(
                                         _collectImageView.frame.origin.x - 3,
                                         _collectImageView.frame.origin.y - 3,
                                         _collectImageView.frame.size.width + 6,
                                         _collectImageView.frame.size.height + 6);
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3
                                                  animations:^{
                                                      _collectImageView.frame = CGRectMake(
                                                              _collectImageView.frame.origin.x + 3,
                                                              _collectImageView.frame.origin.y + 3,
                                                              _collectImageView.frame.size.width - 6,
                                                              _collectImageView.frame.size.height - 6);
                                                  }];
                             }];
        }
        _isClick = NO;
    } else {
        _collectImageView.image = [self starImage];
    }
    if (listType == FMListTypeCollect) {
        _collectCount.hidden = YES;
        self.frame = CGRectMake(300 - 14 - 35, 14, 35, 26);
    } else {
        _collectCount.text = itemDO.collectNum;
        CGSize size = [_collectCount.text sizeWithFont:_collectCount.font
                                     constrainedToSize:CGSizeMake(100, 15)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        _collectCount.frame = CGRectMake(30, 5.5, size.width, size.height);
        self.frame = CGRectMake(300 - 14 - size.width - 40, 14, size.width + 40, 26);
    }
}

- (void)touchView:(id)sender {
    if (_isStartCollect) {
        return;
    }
    _isClick = YES;
    _isStartCollect = YES;
     if (_clickCollect) {
         _clickCollect();
     }
}

- (void)setClickBlock:(void(^)())block {
    _clickCollect = block;
}

- (UIImage *)starImage {
    return [UIImage imageWithFileName:@"star_icon.png"];
}

- (UIImage *)starHighlightImage {
    return [UIImage imageWithFileName:@"star_highlight_icon.png"];
}

@end