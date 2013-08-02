//
// Created by henson on 4/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
//

#import <huoyan/huoyan.h>
#import "FMBaseViewController.h"

typedef enum {
    FMShipmentDefault,
    FMShipmentMessage,
} FMShipmentFrom;

@class FMOrderList;

@interface FMShipmentsViewController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

- (id)initWithTid:(long long int)tid itemId:(NSString *)itemId from:(FMShipmentFrom)from;

@end