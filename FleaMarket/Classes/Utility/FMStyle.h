// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMStyle : NSObject

+ (FMStyle *)instance;

@end

@interface FMFontSize : NSObject

//加载更多
@property (nonatomic, strong) UIFont *loadMoreLabelSize;

@property (nonatomic, strong) UIFont *cellLabelSize;

+ (FMFontSize *)instance;

@end

@interface FMColor : NSObject

//加载更多
@property (nonatomic, strong) UIColor *loadMoreLabelColor;

//common
@property (nonatomic, strong) UIColor *viewControllerBgColor;
@property (nonatomic, strong) UIColor *viewControllerBgGrayColor;

@property (nonatomic, strong) UIColor *cellColor;

@property (nonatomic, strong) UIColor *priceColor;

+ (FMColor *)instance;

@end