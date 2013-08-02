//
//  FMTradeMessageInfo.h
//  FleaMarket
//
//  Created by Henson on 11/02/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

typedef enum {
    NO_ACTION = 0,
    FMMessageTradeBuy = 1,
    FMMessageTradeSell = 2
} FMMessageTradeType;

typedef enum {
    NO_SHARE_ACTION = 0,
    FMMessageShareBuy = 1,
    FMMessageShareSell = 2
} FMMessageShareType;

@interface FMTradeMessageInfo : NSObject {
    NSString *_desc;
    FMMessageTradeType tradeType;
    NSString *_orderId;
    NSString *_actionName;
}

@property(nonatomic, copy) NSString *desc;
@property(nonatomic) FMMessageTradeType tradeType;
@property(nonatomic) FMMessageShareType shareType;
@property(nonatomic, copy) NSString *orderId;
@property(nonatomic, copy) NSString *actionName;

@end
