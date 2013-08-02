// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMThemeDOList;

@interface FMThemeService : FMBaseService

+ (void)getThemes:(NSUInteger)page result:(void (^)(BOOL, FMThemeDOList *, NSString *))result;

@end