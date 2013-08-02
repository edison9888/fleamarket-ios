// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMItemCommentDOList : NSObject

@annotate(FMItemCommentDOList, TBIU_ANN_TYPE : @"FMItemCommentDO")
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, copy) NSString *serverTime;
@property(nonatomic, assign) NSInteger *totalCount;
@property(nonatomic, assign) BOOL nextPage;

@end

@interface FMItemCommentDO : NSObject

@property(nonatomic, assign) long long commentId;
@property(nonatomic, assign) long long itemId;
@property(nonatomic, assign) long long reporterId;
@property(nonatomic, assign) long long sellerId;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *reportTime;
@property(nonatomic, copy) NSString *reporterName;
@property(nonatomic, copy) NSString *reporterNick;
@property(nonatomic, copy) NSString *sellerNick;
@property(nonatomic, copy) NSString *voiceUrl;
@property(nonatomic, copy) NSNumber *voiceTime;

- (NSString *)contentWithEmoji;

- (BOOL)voiceIsEmpty;

@end