// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMStyle.h"

@implementation FMStyle {

}

+ (FMStyle *)instance {
    static FMStyle *_instance = nil;
    static dispatch_once_t _oncePredicate_FMStyle;

    dispatch_once(&_oncePredicate_FMStyle, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}
@end

@implementation FMFontSize {
@private
    UIFont *_loadMoreLabelSize;
    UIFont *_cellLabelSize;
}

@synthesize loadMoreLabelSize = _loadMoreLabelSize;

@synthesize cellLabelSize = _cellLabelSize;

+ (FMFontSize *)instance {
    static FMFontSize *_instance = nil;
    static dispatch_once_t _oncePredicate_FMFontSize;

    dispatch_once(&_oncePredicate_FMFontSize, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (id)init {
    if (self = [super init]) {
        [self initLoadMoreSize];

        _cellLabelSize = FMFont(NO, 15);
    }
    return self;
}

//加载更多
- (void)initLoadMoreSize {
    _loadMoreLabelSize = FMFont(NO, 14);
}

@end

@implementation FMColor {
@private
    UIColor *_loadMoreLabelColor;
    UIColor *_viewControllerBgColor;
    UIColor *_cellColor;
    UIColor *_priceColor;
}

@synthesize loadMoreLabelColor = _loadMoreLabelColor;
@synthesize viewControllerBgColor = _viewControllerBgColor;

@synthesize cellColor = _cellColor;

@synthesize priceColor = _priceColor;

+ (FMColor *)instance {
    static FMColor *_instance = nil;
    static dispatch_once_t _oncePredicate_FMColor;

    dispatch_once(&_oncePredicate_FMColor, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (id)init {
    if (self = [super init]) {
        [self initLoadMoreColor];
        [self initCommon];

        _cellColor = FMColorWithRed(74, 76, 77);

        _priceColor = FMColorWithRed(0xff, 0x4e, 0x6e);
    }
    return self;
}

//加载更多
- (void)initLoadMoreColor {
    _loadMoreLabelColor = FMColorWithRed(0x33, 0x33, 0x33);
}

- (void)initCommon {
    _viewControllerBgColor = [UIColor whiteColor]; //FMColorWithRed(236, 236, 236);
    _viewControllerBgGrayColor = FMColorWithRed(236, 236, 236);
}

@end