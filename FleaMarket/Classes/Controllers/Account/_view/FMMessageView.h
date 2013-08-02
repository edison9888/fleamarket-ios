//
// Created by yuanxiao on 13-7-4.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"
#import "FMMessageViewController.h"

@class FMMessageList;
@class FMItemCommentDO;


@interface FMMessageView : FMBaseScrollView

@property (nonatomic, strong) FMMessageList *messageList;

- (id)initWithFrame:(CGRect)frame messageViewType:(FMMessageViewType)messageViewType;

- (void)setEdit:(BOOL)edit;

- (void)setRequestBlock:(void(^)(NSUInteger pageNum))block;

- (void)setDeleteComment:(void(^)(FMItemCommentDO *commentDO))block;

- (void)refreshView:(NSUInteger)pageNum;

- (void)scrollToHeight:(CGFloat)height;

@end