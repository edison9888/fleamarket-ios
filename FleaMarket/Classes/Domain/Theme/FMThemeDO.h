//
// Created by henson on 6/18/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMThemeDOList : NSObject

@annotate(FMThemeDOList, TBIU_ANN_TYPE : @"FMThemeDO")
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, assign) BOOL nextPage;
@property(nonatomic, copy) NSString *serverTime;
@property(nonatomic, assign) NSUInteger totalCount;

@end

@interface FMThemeDO : NSObject

@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *headPicUrl;
@property(nonatomic, copy) NSString *nick;
@property(nonatomic, copy) NSString *introduce;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *picUrl;
@property(nonatomic, copy) NSString *from;
@property(nonatomic, strong) NSArray *itemUrls;
@property(nonatomic, copy) NSString *gmtCreate;

@end