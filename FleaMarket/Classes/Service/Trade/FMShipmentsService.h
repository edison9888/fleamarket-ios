// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMLogisticsCompanyDO;

@interface FMShipmentsService : NSObject

+ (void)dummyShip:(NSString *)tid result:(void (^)(BOOL, BOOL, NSString *))result;

+ (void)offlineShip:(NSString *)tid
   logisticsCompany:(FMLogisticsCompanyDO *)logisticsCompany
             outSid:(NSString *)outSid
             result:(void (^)(BOOL, BOOL, NSString *))result;

+ (void)getLogisticsCompanies:(void (^)(BOOL, id, NSString *))result;

+ (void)modifyShipment:(NSString *)tid logisticsCompany:(FMLogisticsCompanyDO *)logisticsCompany outSid:(NSString *)outSid result:(void (^)(BOOL, BOOL, NSString *))result;
@end