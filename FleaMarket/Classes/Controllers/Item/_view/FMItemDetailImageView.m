// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMItemDetailImageView.h"
#import "FMItemDO.h"
#import "FMImageView.h"
#import "UIImage+Helper.h"
#import "FMPriceView.h"

#define kItemImageMargin (15)
#define kItemImageNormalHeight  (320 - kItemImageMargin * 2)
#define kItemImageExtendHeight  (320)

@implementation FMItemDetailImageView {
    __weak UIScrollView *_scrollView;
    FMPriceView *_priceView;
    __weak FMItemDO *_itemDO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect scrollRect = {{kItemImageMargin, 0}, {kItemImageNormalHeight, kItemImageNormalHeight}};
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        scrollView.backgroundColor = FMColorWithRed(243, 243, 243);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.clipsToBounds = NO;
        scrollView.userInteractionEnabled = YES;
        [self addSubview:scrollView];
        _scrollView = scrollView;

        CGRect priceRect = {{0, kItemImageNormalHeight - 102}, {FM_SCREEN_WIDTH, 102}};
        FMPriceView *priceView = [[FMPriceView alloc] initWithFrame:priceRect];
        priceView.userInteractionEnabled = NO;
        priceView.backgroundColor = [UIColor clearColor];
        [self addSubview:priceView];
        _priceView = priceView;
    }

    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[FMImageView class]]) {
        return view;
    }

    return _scrollView;
}

- (UIImage *)getFirstImage {
    if (_scrollView.subviews.count > 0) {
        FMImageView *imageView = [_scrollView.subviews objectAtIndex:0];
        return imageView.image;
    }
    return nil;
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;

    [_priceView setItemDO:itemDO];
    [self resetPriceViewFrame];

    [self resetScrollView];

    __weak FMItemDetailImageView *selfWeak = self;

    if ([_itemDO.imageUrls count] < 1) {
        FMImageView *imageView = [self createImageView];
        imageView.image = [UIImage imageWithFileName:@"item_default_image.png"];
        [_scrollView addSubview:imageView];
        return;
    }

    if ([_itemDO.imageUrls count] == 1) {
        NSString *urlString = [_itemDO.imageUrls objectAtIndex:(NSUInteger) 0];
        FMImageView *imageView = [self createImageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = 0;
        [imageView setWebPImageWithURL:urlString
                         imageScaleType:FMImageScale640x640
                       placeholderImage:FMPlaceholderImage
                                success:^(UIImage *image, FMImageView *view) {
                                    view.image = [image resetSquareImage];
                                }
                                failure:^(NSError *error, FMImageView *view) {

                                }];
        imageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak touchAction:0];
        };
        [_scrollView addSubview:imageView];
        return;
    }

    for (int i=0; i< [_itemDO.imageUrls count]; i++) {
        NSString *urlString = [_itemDO.imageUrls objectAtIndex:(NSUInteger) i];
        CGRect imageRect = {{(kItemImageNormalHeight + 5) * i, 0},{kItemImageNormalHeight, kItemImageNormalHeight}};
        FMImageView *imageView = [self createImageView];
        imageView.userInteractionEnabled = YES;
        imageView.frame = imageRect;
        imageView.tag = i;
        [imageView setWebPImageWithURL:urlString
                        imageScaleType:FMImageScale640x640
                placeholderImage:FMPlaceholderImage
                               success:^(UIImage *image, FMImageView *view) {
                                   view.image = [image resetSquareImage];
                               }
                               failure:^(NSError *error, FMImageView *view) {

                               }];
        imageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak touchAction:(NSUInteger) i];
        };
        [_scrollView addSubview:imageView];
    }

    [self setNeedsDisplay];
}

- (void)touchAction:(NSUInteger)index {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushImageDetailViewController:page:),[NSNumber numberWithInt:index]);
}

- (FMImageView *)createImageView {
    FMImageView *imageView = [[FMImageView alloc] initWithFrame:CGRectZero];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shadowOffset = CGSizeMake(-1.f, 1.f);
    imageView.layer.shadowOpacity = 0.5f;
    imageView.layer.shadowRadius = 1.0f;
    imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
    CGRect imageRect = {{0, 0},{kItemImageExtendHeight, kItemImageExtendHeight}};
    imageView.frame = imageRect;
    return imageView;
}

- (void)resetScrollView {
    if ([_itemDO.imageUrls count] <= 1) {
        CGRect scrollRect = {{0, 0}, {kItemImageExtendHeight, kItemImageExtendHeight}};
        _scrollView.frame = scrollRect;
        _scrollView.contentSize = CGSizeMake(kItemImageExtendHeight + 0.5, kItemImageExtendHeight);
        return;
    }
    CGRect scrollRect = {{kItemImageMargin, 0}, {kItemImageNormalHeight + 5, kItemImageNormalHeight}};
    _scrollView.frame = scrollRect;
    _scrollView.contentSize = CGSizeMake([_itemDO.imageUrls count] * (kItemImageNormalHeight + 5), kItemImageNormalHeight);
    return;
}

- (void)resetPriceViewFrame {
    CGRect priceRect = _priceView.frame;
    if ([_itemDO.imageUrls count] < 2) {
        priceRect.origin.y += 30;
    }
    _priceView.frame = priceRect;
}

+ (float)viewHeight:(FMItemDO *)itemDO {
    if ([itemDO.imageUrls count] < 2) {
        return kItemImageExtendHeight;
    }
    return kItemImageNormalHeight;
}

- (void)dealloc {
    FMLog(@"dealloc:%@", [self description]);
}

@end