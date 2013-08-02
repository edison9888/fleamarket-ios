// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMLogisticsCompanyDO.h"


@implementation FMLogisticsCompanyDO {

@private
    NSString *_id;
    NSString *_name;
    NSString *_reg_mail_no;
    NSString *_code;
}

@synthesize id = _id;
@synthesize name = _name;
@synthesize reg_mail_no = _reg_mail_no;
@synthesize code = _code;

- (id)copyWithZone:(NSZone *)zone {
    FMLogisticsCompanyDO *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.id = self.id;
        copy.name = self.name;
        copy.reg_mail_no = self.reg_mail_no;
        copy.code = self.code;
    }

    return copy;
}

@end