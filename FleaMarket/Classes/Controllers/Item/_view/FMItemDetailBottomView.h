// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMItemDO;

@interface FMItemDetailBottomItemView : UIView

@property(nonatomic, strong) UIImage *iconImage;
@property(nonatomic, strong) UIImage *highlightImage;
@property(nonatomic, assign) BOOL isHighlight;
@property(nonatomic, copy) NSString *badge;

- (id)initWithIconImage:(UIImage *)iconImage;

- (void)addBadge;

- (void)reduceBadge;

@end

@interface FMItemDetailBottomView : UIImageView

@property(nonatomic, assign) BOOL isFavorite;

- (void)setItemDO:(FMItemDO *)itemDO;

- (void)setSubscribed:(BOOL)isSubscribed;

- (void)setFavoriteBadge:(NSString *)badge;

- (void)setCommentBadge:(NSString *)badge;

- (void)setBuyAction:(void (^)(void))block;

- (void)setShareAction:(void (^)(void))block;

- (void)setEditAction:(void (^)(void))block;

- (void)setOperationAction:(void (^)(void))block;

- (void)setItems:(NSArray *)items;

@end