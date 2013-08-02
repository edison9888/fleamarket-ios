// 
// Created by henson on 12/13/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef enum {
    FM_FILTER_FIELD_CATEGORY,
    FM_FILTER_FIELD_STUFF_STATUS,
    FM_FILTER_FIELD_PRICE,
    FM_FILTER_FIELD_LOCATION,
    FM_FILTER_FIELD_TRADE,
    FM_FILTER_FIELD_SORT
} FMFilterFieldType;


@interface FMFilterFieldDO : NSObject

@property(nonatomic, assign) FMFilterFieldType key;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *value;

@end