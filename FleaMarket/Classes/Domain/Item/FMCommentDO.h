// 
// Created by henson on 7/3/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMCommentDO : NSObject

@property(nonatomic, assign) long long sellerId;
@property(nonatomic, copy) NSString *sellerName;
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *voiceUrl;
@property(nonatomic, copy) NSNumber *voiceTime;

- (BOOL)hasVoice;
@end