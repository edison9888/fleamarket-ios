// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMDeliveryDOList : NSObject

@annotate(FMDeliveryDOList, TBIU_ANN_TYPE : @"FMDeliveryDO")
@property(nonatomic, strong) NSArray *addressList;

@end

@interface FMDeliveryDO : NSObject

@property(nonatomic, copy) NSString *deliverId;
@property(nonatomic, copy) NSString *addressDetail;
@property(nonatomic, copy) NSString *area;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *post;
@property(nonatomic, copy) NSString *mobile;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *fullName;

- (NSString *)getFullAddress;

@end