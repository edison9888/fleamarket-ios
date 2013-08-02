// 
// Created by henson on 12/14/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMFilterFieldOptionDO : NSObject

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *value;

+ (FMFilterFieldOptionDO *)objectWithTitle:(NSString *)title value:(NSString *)value;

@end