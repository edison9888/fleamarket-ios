// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMLogisticsCompanyDO : NSObject <NSCopying>

@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *code;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *reg_mail_no;

- (id)copyWithZone:(NSZone *)zone;

@end