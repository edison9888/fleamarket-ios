//
//  FMSidePanelNavItemView.m
//  FleaMarket
//
//  Created by Caiyu on 13-7-15.
//  Copyright (c) 2013年 taobao.com. All rights reserved.
//

#import "FMSidePanelNavItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Helper.h"
#import "FMRootViewController.h"


@implementation FMSidePanelNavItemView {
@private
    void (^_navItemBlock)(FMSidePanelNavItemView *);
    
    FMRootViewControllerDO *_dataDO;
    UILabel *_itemTitleLabel;

    UILabel *_unreadCountLabel;
    UIView *_unreadCountView;
}

@synthesize dataDO = _dataDO;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        [self addTarget:self action:@selector(toucheItem:) forControlEvents:UIControlEventTouchUpInside];
        
        _itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, frame.size.width, 20)];
        _itemTitleLabel.backgroundColor = [UIColor clearColor];
        _itemTitleLabel.font = FMFont(YES, 14);
        _itemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_itemTitleLabel];

        _unreadCountView = [[UIView alloc] init];
        _unreadCountView.layer.cornerRadius = 10;
        _unreadCountView.backgroundColor = [UIColor whiteColor];
        [self.imageView addSubview:_unreadCountView];

        _unreadCountLabel = [[UILabel alloc] init];
        _unreadCountLabel.backgroundColor = FMColorWithRed(0xff, 0x59, 0x18);
        _unreadCountLabel.layer.cornerRadius = 8;
        _unreadCountLabel.textAlignment = NSTextAlignmentCenter;
        _unreadCountLabel.font = FMFont(NO, 12);
        _unreadCountLabel.textColor = [UIColor whiteColor];
        [_unreadCountView addSubview:_unreadCountLabel];
    }
    return self;
}

- (void)setDataDO:(FMRootViewControllerDO *)dataDO {
    _dataDO = dataDO;
    _itemTitleLabel.text = dataDO.itemName;
    UIImage *image = [UIImage imageWithFileName:dataDO.itemImage];
    [self setImage:image
          forState:UIControlStateNormal];
    [self setImage:[UIImage imageWithFileName:dataDO.itemSelectedImage]
          forState:UIControlStateHighlighted];
    [self setImage:[UIImage imageWithFileName:dataDO.itemSelectedImage]
          forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage createImageWithColor:dataDO.itemBGColor]
                    forState:UIControlStateNormal];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, image.size.height, -image.size.width + 27)];
    self.imageView.contentMode = UIViewContentModeCenter;

    if (dataDO.tapType == FMTapTypeAccount) {

    }
}

- (void)setClickItemBlock:(void(^)(FMSidePanelNavItemView *))block {
    _navItemBlock = block;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _itemTitleLabel.textColor = _dataDO.itemNameSelectedColor;
    [super setSelected:!highlighted];
}

- (void)setSelected:(BOOL)isSelected{
    [super setSelected:isSelected];
    if (isSelected) {
        _itemTitleLabel.textColor = _dataDO.itemNameSelectedColor;
    } else {
        _itemTitleLabel.textColor = [UIColor whiteColor];
    }
    [self buttonAnimation:isSelected];
}

- (void)setUnreadCount:(NSInteger)unreadCount {
    _unreadCount = unreadCount;
    NSString *strCount;
    if (unreadCount == 0){
        _unreadCountView.hidden = YES;
        return;
    }
    _unreadCountView.hidden = NO;
    if (unreadCount > 99) {
        strCount = @"99+";
    } else {
        strCount = [NSString stringWithFormat:@"%d", unreadCount];
    }
    _unreadCountLabel.text = strCount;
    CGSize size = [strCount sizeWithFont:_unreadCountLabel.font
                       constrainedToSize:CGSizeMake(300 - 24, 300)
                           lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat width;
    if (size.width > 10) {
        width = size.width + 10;
    } else {
        width = 20;
    }
    CGRect rect = CGRectMake(2, 2, width - 4, 16);
    _unreadCountLabel.frame = rect;

    rect = CGRectMake(20, -5, width, 20);
    _unreadCountView.frame = rect;
    self.imageView.clipsToBounds = NO;
}

- (void)buttonAnimation:(BOOL)isAnimation{
    CGFloat animationSize;
    CGFloat alpha;
    if (isAnimation) {
        animationSize = 5;
        alpha = 1.0;
    } else {
        animationSize = -5;
        alpha = 0.3;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = CGRectMake(
                                                 self.frame.origin.x - animationSize,
                                                 self.frame.origin.y - animationSize,
                                                 self.frame.size.width + animationSize * 2,
                                                 self.frame.size.height + animationSize * 2);
                         _itemTitleLabel.frame = CGRectMake(animationSize, 70 + animationSize,
                                                            kSidePanelNavItemWidth, 20);
                         self.alpha = alpha;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              self.frame = CGRectMake(
                                                                      self.frame.origin.x + animationSize,
                                                                      self.frame.origin.y + animationSize,
                                                                      self.frame.size.width - animationSize * 2,
                                                                      self.frame.size.height - animationSize * 2);
                                              _itemTitleLabel.frame = CGRectMake(0, 70,
                                                                                 kSidePanelNavItemWidth, 20);
                                              self.alpha = 1;
                                          }
                                          completion:^(BOOL finishedd) {
                                          }];
                     }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)toucheItem:(id)sender {
    if (_navItemBlock) {
        _navItemBlock(self);
    }
}

@end
