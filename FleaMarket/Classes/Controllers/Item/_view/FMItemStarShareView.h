// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMItemDO;

@interface FMItemStarShareView : UIView

@property(nonatomic, assign) BOOL isStar;

+ (float)viewWidth:(FMItemDO *)itemDO;

- (void)setFavoriteAction:(void (^)(FMItemStarShareView *, FMItemDO *))block;

- (void)setShareAction:(void (^)(FMItemStarShareView *, FMItemDO *))block;

- (void)setItemDO:(FMItemDO *)itemDO;

@end