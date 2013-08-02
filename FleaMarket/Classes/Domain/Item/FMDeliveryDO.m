// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMDeliveryDO.h"

@implementation FMDeliveryDOList

@end

@implementation FMDeliveryDO

- (NSString *)getFullAddress {
    NSArray *array = @[self.province, self.city, self.area, self.addressDetail];
    return [array componentsJoinedByString:@""];
}

@end