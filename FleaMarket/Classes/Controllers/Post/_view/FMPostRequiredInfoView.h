// 
// Created by henson on 6/26/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostTextIndicationView.h"

@class FMItemDO;
@class FMPostImageView;

@interface FMPostRequiredInfoView : UIScrollView <UIScrollViewDelegate>

@property(nonatomic, strong) FMItemDO *itemDO;

@property(nonatomic, weak, readonly) FMPostImageView *postImageView;

- (id)initWithFrame:(CGRect)frame
             itemDO:(FMItemDO *)itemDO
       isShowResell:(BOOL)isShow;

- (void)setTitleText:(NSString *)text;

- (void)setTextIndicationState:(FMPostIndicationState)state;

- (void)refreshView;

- (void)setResellPromptHidden:(BOOL)hidden;

@end