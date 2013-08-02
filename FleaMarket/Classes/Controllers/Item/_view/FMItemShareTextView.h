// 
// Created by henson on 7/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kShareType) {
    kShareTypeWeibo,
    kShareTypeDouban,
};

@class FMImageView;
@class FMItemDO;

@interface FMItemShareTextView : UIView

@property(nonatomic, assign) kShareType type;

- (void)setFocus;

- (void)shareWeiboAction:(void (^)(UITextView *, FMItemShareTextView *view))block;

- (void)setItemDO:(FMItemDO *)itemDO;

- (void)closeShareView;

@end