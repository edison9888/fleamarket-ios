// 
// Created by henson on 12/14/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMFilterFieldOptionDO.h"

@implementation FMFilterFieldOptionDO

@synthesize title = _title;
@synthesize value = _value;

+ (FMFilterFieldOptionDO *)objectWithTitle:(NSString *)title value:(NSString *)value {
    __autoreleasing FMFilterFieldOptionDO *optionDO = [[FMFilterFieldOptionDO alloc] init];
    optionDO.title = title;
    optionDO.value = value;
    return optionDO;
}

@end