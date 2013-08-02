//
// Created by henson on 2/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
//

@interface FMTaoBaoTradeList : NSObject

@property(nonatomic, assign) BOOL nextPage;
@property(nonatomic, copy) NSString *serverTime;
@property(nonatomic, assign) NSUInteger totalCount;
@property(nonatomic, assign) long onlineTotal;
@annotate(FMTaoBaoTradeList, TBIU_ANN_TYPE : @"FMTaoBaoTrade")
@property(nonatomic, strong) NSArray *items;

@end

@interface FMTaoBaoTrade : NSObject

@property(nonatomic, assign) long long id;
@property(nonatomic, assign) NSInteger payStatus;
@property(nonatomic, copy) NSString *payment;
@property(nonatomic, copy) NSString *picUrl;
@property(nonatomic, copy) NSString *postFee;
@property(nonatomic, copy) NSString *postInsureFee;  //运费险
@annotate(FMTaoBaoTrade, TBIU_ANN_TYPE : @"FMTaoBaoTradeOrder")
@property(nonatomic, strong) NSArray *orders;
@property(nonatomic, assign) NSInteger totalCount;
@property(nonatomic, copy) NSString *endTime;

@end

@interface FMTaoBaoTradeOrder : NSObject <NSCoding>

@property(nonatomic, assign) long long id;
@property(nonatomic, assign) long long itemId;
@property(nonatomic, assign) NSInteger num;
@property(nonatomic, copy) NSString *picUrl;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) BOOL archive;
@property(nonatomic, assign) BOOL virtual;   //是否是虚拟宝贝
@property(nonatomic, assign) NSInteger status; //是否正在转卖中
@property(nonatomic, copy) NSString *oriPrice; //实付价格

@end