//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface FMListResultDO : NSObject

@property(nonatomic) BOOL isSuccess;
@property(nonatomic) unsigned long totalCount;
@property(nonatomic, strong) NSMutableArray *data;
@property(nonatomic, copy) NSString *error;
@property(nonatomic, copy) NSString *serverTime;

- (BOOL)isNext;

@end

@interface FMTrade : NSObject

@annotate(FMTrade, TBIU_ANN_TYPE : @"FMOrderList")
@property(nonatomic, strong) NSArray *trade;

@end

@interface FMOrder : NSObject

@annotate(FMOrder, TBIU_ANN_TYPE : @"FMOrderDetail")
@property(nonatomic, strong) NSArray *order;


@end

@interface FMOrderList : NSObject

@property(nonatomic, copy) NSString *payment;
@property(nonatomic, copy) NSString *post_fee;
@property(nonatomic, strong) FMOrder *orders;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *alipay_no;
@property(nonatomic, copy) NSString *tid;

@property (nonatomic, copy)NSString *num_iid;
@property(nonatomic, copy) NSString *buyer_email;
@property(nonatomic, copy) NSString *buyer_nick;
@property(nonatomic, copy) NSString *buyer_message;
@property(nonatomic, copy) NSString *modified;
@property(nonatomic, assign) NSInteger num;
@property(nonatomic, copy) NSString *pic_path;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *receiver_address;
@property(nonatomic, copy) NSString *receiver_city;
@property(nonatomic, copy) NSString *receiver_district;
@property(nonatomic, copy) NSString *receiver_mobile;
@property(nonatomic, copy) NSString *receiver_name;
@property(nonatomic, copy) NSString *receiver_phone;
@property(nonatomic, copy) NSString *receiver_state;

- (NSString *)getStatus;

@end

@interface FMOrderDetail : NSObject

@property(nonatomic) NSInteger num;
@property(nonatomic, copy) NSString *oid;
@property(nonatomic, copy) NSString *num_iid;
@property(nonatomic, copy) NSString *pic_path;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *shipping_type;
@property(nonatomic, copy) NSString *consign_time;
@property(nonatomic, copy) NSString *logistics_company;
@property(nonatomic, copy) NSString *invoice_no;

- (BOOL)isDummyShipment;

@end