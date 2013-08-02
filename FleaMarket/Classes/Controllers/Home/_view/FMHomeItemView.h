// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMHomeItemViewProtocol.h"

@class FMHomeItemDO;

typedef NS_ENUM(NSInteger, FMHomeItemIconType)
{
    FMHomeItemIconNormal = 0,
    FMHomeItemIconVoice,
};

@interface FMHomeItemIconView : UIView

@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) UIImage *iconImage;
@property(nonatomic, assign) FMHomeItemIconType type;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end

@interface FMHomeItemView : UIView <FMHomeItemViewProtocol>

- (FMHomeItemDO *)homeItemDO;
- (void)setHomeItemDO:(FMHomeItemDO *)homeItemDO;

@end