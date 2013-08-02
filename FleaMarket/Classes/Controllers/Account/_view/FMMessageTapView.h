//
// Created by yuanxiao on 13-7-4.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMMessageViewController.h"

@interface FMMessageTapItemView : UIButton

- (void)setTitle:(NSString *)title;

- (void)setCount:(NSInteger)count;

- (void)setSelect:(BOOL)select;

@end

@interface FMMessageTapView : UIView

@property (nonatomic, strong) FMMessageViewInfo *messageInfo;

- (void)setTouchMessageTapItem:(void(^)(FMMessageViewType messageViewType))block;

- (void)selectMessageTap:(FMMessageViewType)messageViewType;

@end