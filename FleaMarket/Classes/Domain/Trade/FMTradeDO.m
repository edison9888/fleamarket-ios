//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMTradeDO.h"
#import "NSString+Helper.h"


@implementation FMListResultDO {

@private
    BOOL _isSuccess;
    unsigned long _totalCount;
    NSMutableArray *_data;
    NSString *_error;
    NSString *_serverTime;
}
@synthesize isSuccess = _isSuccess;
@synthesize totalCount = _totalCount;
@synthesize data = _data;
@synthesize error = _error;
@synthesize serverTime = _serverTime;

- (BOOL)isNext {
    return _totalCount > _data.count;
}

@end

@implementation FMTrade {
@private
    NSArray *_trade;
}
@synthesize trade = _trade;
@end

@implementation FMOrderList {

@private
    NSString *_buyer_email;
    NSString *_buyer_nick;
    NSString *_modified;
    NSInteger _num;
    NSString *_pic_path;
    NSString *_price;
    NSString *_receiver_address;
    NSString *_receiver_district;
    NSString *_receiver_state;
    NSString *_receiver_phone;
    NSString *_receiver_name;
    NSString *_receiver_mobile;
    NSString *_receiver_city;
    NSString *_buyer_message;
    NSString *_num_iid;
    NSString *_payment;
    NSString *_post_fee;
    NSString *_status;
    NSString *_alipay_no;
    FMOrder *_orders;
    NSString *_tid;
}

@synthesize payment = _payment;
@synthesize post_fee = _post_fee;
@synthesize orders = _orders;
@synthesize status = _status;
@synthesize alipay_no = _alipay_no;
@synthesize tid = _tid;

@synthesize buyer_email = _buyer_email;
@synthesize buyer_nick = _buyer_nick;
@synthesize modified = _modified;
@synthesize num = _num;
@synthesize pic_path = _pic_path;
@synthesize price = _price;
@synthesize receiver_address = _receiver_address;
@synthesize receiver_district = _receiver_district;
@synthesize receiver_state = _receiver_state;
@synthesize receiver_phone = _receiver_phone;
@synthesize receiver_name = _receiver_name;
@synthesize receiver_mobile = _receiver_mobile;
@synthesize receiver_city = _receiver_city;

@synthesize buyer_message = _buyer_message;

@synthesize num_iid = _num_iid;

-(NSString*)  getStatus {
    if ([_status isEqualToString:@"WAIT_BUYER_PAY"]) {
        return @"等待买家付款";
    }
    if ([_status isEqualToString:@"TRADE_NO_CREATE_PAY"]) {
        return @"没有创建支付宝交易";
    }
    if ([_status isEqualToString:@"PLS_USE_ZFB"]) {
        return @"等待买家付款";
    }
    if ([_status isEqualToString:@"TRADE_FINISHED"]) {
        return @"交易成功";
    }
    if ([_status isEqualToString:@"TRADE_CLOSED"]) {
        return @"交易关闭";
    }
    if ([_status isEqualToString:@"TRADE_CLOSED_BY_TAOBAO"]) {
        return @"交易关闭";
    }
    if ([_status isEqualToString:@"TRADE_CLOSED_OF_HISTORY"]) {
        return @"交易关闭";
    }
    if ([_status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"]) {
        return @"卖家已发货";
    }
    if ([_status isEqualToString:@"WAIT_SELLER_SEND_GOODS"]) {
        return @"等待卖家发货";
    }
    if ([_status isEqualToString:@"TRADE_BUYER_SIGNED"]) {
        return @"买家已签收";
    }
    return nil;
}

@end

@implementation FMOrder {
@private
    NSArray *_order;
}
@synthesize order = _order;


@end

@implementation FMOrderDetail {
@private
    NSString *_shipping_type;
    NSString *_consign_time;
    NSString *_logistics_company;
    NSString *_invoice_no;
    NSString *_num_iid;
    NSInteger _num;
    NSString *_oid;
    NSString *_pic_path;
    NSString *_price;
    NSString *_title;
}
@synthesize num = _num;
@synthesize oid = _oid;
@synthesize pic_path = _pic_path;
@synthesize price = _price;
@synthesize title = _title;

@synthesize shipping_type = _shipping_type;
@synthesize consign_time = _consign_time;
@synthesize logistics_company = _logistics_company;
@synthesize invoice_no = _invoice_no;
@synthesize num_iid = _num_iid;

- (BOOL)isDummyShipment {
    if (([_shipping_type isEqualToString:@"express"] && (!_invoice_no || [_invoice_no isBlank]))
            || [_shipping_type isEqualToString:@"virtual"]) {
        return YES;
    }
    return NO;
}

@end