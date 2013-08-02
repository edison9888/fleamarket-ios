//
// Created by yuanxiao on 13-7-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBGlobalFacade.h>
#import "FMHomeScrollImageView.h"
#import "UIImage+Helper.h"
#import "TBMBDefaultReceiverImpl.h"

@interface FMHomeScrollImageView () <TBMBMessageReceiver>
@end

@implementation FMHomeScrollImageView {
@private
    NSUInteger _page;
    BOOL _isSubscribeNotification;
    NSArray *_picUrls;
    BOOL _isSquare;
    BOOL _isBanner;
    FMImageScaleType _imageScaleType;

    FMImageView *_fromView;
    FMImageView *_toView;

    __weak FMImageView *_currentView;

    TBMBDefaultReceiverImpl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setData:(NSArray *)array
       isBanner:(BOOL)isBanner
 imageScaleType:(FMImageScaleType)imageScaleType {
    _isBanner = isBanner;
    [self setData:array
         isSquare:NO
   imageScaleType:imageScaleType];
}

- (void)setData:(NSArray *)array
       isSquare:(BOOL)isSquare
 imageScaleType:(FMImageScaleType)imageScaleType  {
    if (array.count == 0) {
        return;
    }
    for (FMImageView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    if (array.count > 1) {
        if (!_isSubscribeNotification) {
            _isSubscribeNotification = YES;
            [[TBMBGlobalFacade instance] subscribeNotification:self];
        }
    } else {
        _isSubscribeNotification = NO;
        [[TBMBGlobalFacade instance] unsubscribeNotification:self];
    }
    _page = 0;
    _isSquare = isSquare;
    _imageScaleType = imageScaleType;
    _picUrls = [NSArray arrayWithArray:array];
    NSString *url = [array objectAtIndex:0];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _fromView = [[FMImageView alloc] initWithFrame:rect];
    if (array.count > 1) {
        _fromView.needlessAnimation = YES;
    }
    [self loadImage:_fromView url:url];
    [self addSubview:_fromView];
}

- (void)loadImage:(FMImageView *)imageView url:(NSString *)url{
    [imageView setWebPImageWithURL:url
                    imageScaleType:_imageScaleType
                  placeholderImage:FMPlaceholderImage
                           success:^(UIImage *image, FMImageView *view) {
                               if (_isBanner) {
                                   view.image = [image resetSquareImage:view.frame.size];
                               }else if (_isSquare) {
                                   view.image = [image resetSquareImage];
                               }
                           }
                           failure:^(NSError *error, FMImageView *view) {

                           }];
}

- (void)$$homeScrollImageView:(id <TBMBNotification>)notification {
    if (random() % 3 == 0) {
        return;
    }
    if (!_toView) {
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _toView = [[FMImageView alloc] initWithFrame:rect];
        _toView.needlessAnimation = YES;
        [self insertSubview:_toView aboveSubview:_fromView];
    }
    FMImageView *fromView;
    FMImageView *toView;
    UIViewAnimationOptions options;
    if (_currentView == _fromView) {
        fromView = _fromView;
        toView = _toView;
        _currentView = _toView;
    } else {
        fromView = _toView;
        toView = _fromView;
        _currentView = _fromView;
    }
    options = UIViewAnimationOptionTransitionFlipFromRight;
    _page++;
    if (_page == _picUrls.count) {
        _page = 0;
    }
    [self loadImage:toView url:[_picUrls objectAtIndex:_page]];
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:options
                    completion:^(BOOL completion) {
                    }];

}

- (void)dealloc {
    [[TBMBGlobalFacade instance] unsubscribeNotification:self];
}

@end