//
// Created by henson on 7/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCommentReplyDO : NSObject

@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) long long int commentId;

@property(nonatomic, assign) long long int sellerId;
@property(nonatomic, copy) NSString *sellerName;

@property(nonatomic, assign) long long int beReplierId;
@property(nonatomic, copy) NSString *beReplierNick;

@property(nonatomic, copy) NSString *voiceUrl;

- (BOOL)hasVoice;

@end