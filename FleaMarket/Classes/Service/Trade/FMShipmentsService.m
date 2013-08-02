// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMShipmentsService.h"
#import "EventDefine.h"
#import "TopInfo.h"
#import "RemoteContext.h"
#import "HandlerDefine.h"
#import "TopHandler.h"
#import "RemoteEvent.h"
#import "FMLogisticsCompanyDO.h"

@implementation FMShipmentsService {

}

+ (void)dummyShip:(NSString *)tid result:(void (^)(BOOL, BOOL, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.logistics.dummy.send" version:@"2.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tid ? : @"", @"tid", nil];
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (result) {
            FMLOG(@"dummyShip.responseData:%@", event.responseData);
            NSDictionary *errorDict = [event.responseData objectForKey:@"error_response"];
            if (errorDict) {
                if ([errorDict objectForKey:@"sub_msg"]) {
                    result(NO, NO, [errorDict objectForKey:@"sub_msg"]);
                    return;
                }
                result(NO, NO, nil);
                return;
            }
            NSDictionary *shipping = [[event.responseData objectForKey:@"logistics_dummy_send_response"] objectForKey:@"shipping"];
            BOOL isSuccess = [[shipping objectForKey:@"is_success"] boolValue];
            if (isSuccess) {
                result(YES, YES, nil);
            } else {
                result(NO, NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            NSError *error = [event.context.errorMessage objectAtIndex:0];
            NSString *errorMessage = error.localizedDescription;
            result(NO, NO, errorMessage);
        }
    }                 forType:TBRO_FAILED];

    [[TopHandler instance] request:context];
}

+ (void)offlineShip:(NSString *)tid
   logisticsCompany:(FMLogisticsCompanyDO *)logisticsCompany
             outSid:(NSString *)outSid
             result:(void (^)(BOOL, BOOL, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.logistics.offline.send" version:@"2.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tid ? : @"", @"tid", outSid, @"out_sid", logisticsCompany.code, @"company_code", nil];
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (result) {
            FMLOG(@"offlineShip.responseData:%@", event.responseData);
            NSDictionary *errorDict = [event.responseData objectForKey:@"error_response"];
            if (errorDict) {
                if ([errorDict objectForKey:@"sub_msg"]) {
                    result(NO, NO, [errorDict objectForKey:@"sub_msg"]);
                    return;
                }
                result(NO, NO, nil);
                return;
            }
            NSDictionary *shipping = [[event.responseData objectForKey:@"logistics_offline_send_response"] objectForKey:@"shipping"];
            BOOL isSuccess = [[shipping objectForKey:@"is_success"] boolValue];
            if (isSuccess) {
                result(YES, YES, nil);
            } else {
                result(NO, NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            NSError *error = [event.context.errorMessage objectAtIndex:0];
            NSString *errorMessage = error.localizedDescription;
            result(NO, NO, errorMessage);
        }
    }                 forType:TBRO_FAILED];

    [[TopHandler instance] request:context];
}

+ (void)getLogisticsCompanies:(void (^)(BOOL, id, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.logistics.companies.get" version:@"2.0"];
    [info addFields:@"id,code,name,reg_mail_no"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (result) {
            NSDictionary *logisticsCompanies = [[event.responseData objectForKey:@"logistics_companies_get_response"] objectForKey:@"logistics_companies"];
            if (logisticsCompanies) {
                result(YES, [logisticsCompanies objectForKey:@"logistics_company"], nil);
            } else {
                result(NO, nil, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            NSError *error = [event.context.errorMessage objectAtIndex:0];
            NSString *errorMessage = error.localizedDescription;
            result(NO, nil, errorMessage);
        }
    }                 forType:TBRO_FAILED];

    [[TopHandler instance] request:context];
}

+ (void)modifyShipment:(NSString *)tid
        logisticsCompany:(FMLogisticsCompanyDO *)logisticsCompany
                  outSid:(NSString *)outSid
                  result:(void (^)(BOOL, BOOL, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.logistics.consign.resend" version:@"2.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tid ? : @"", @"tid", outSid, @"out_sid", logisticsCompany.code, @"company_code", nil];
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (result) {
            FMLOG(@"taobao.logistics.consign.resend.responseData:%@", event.responseData);
            NSDictionary *errorDict = [event.responseData objectForKey:@"error_response"];
            if (errorDict) {
                if ([errorDict objectForKey:@"sub_msg"]) {
                    result(NO, NO, [errorDict objectForKey:@"sub_msg"]);
                    return;
                }
                result(NO, NO, nil);
                return;
            }
            NSDictionary *shipping = [[event.responseData objectForKey:@"logistics_consign_resend_response"] objectForKey:@"shipping"];
            BOOL isSuccess = [[shipping objectForKey:@"is_success"] boolValue];
            if (isSuccess) {
                result(YES, YES, nil);
            } else {
                result(NO, NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            NSError *error = [event.context.errorMessage objectAtIndex:0];
            NSString *errorMessage = error.localizedDescription;
            result(NO, NO, errorMessage);
        }
    }                 forType:TBRO_FAILED];

    [[TopHandler instance] request:context];
}

@end