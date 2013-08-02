// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

#define kFMPostTitleTextField    @"kFMPostTitleTextField"
#define kFMPostPriceTextField    @"kFMPostPriceTextField"

@class FMItemDO;

@interface FMPostTitlePriceView : UIView <UITextFieldDelegate>

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO;

- (void)refreshView;

- (void)setTitleText:(NSString *)text;

@end