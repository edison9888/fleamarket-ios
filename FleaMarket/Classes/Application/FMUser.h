//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午10:42.
//


#import <Foundation/Foundation.h>


@interface FMUser : NSObject
@property(atomic, copy) NSString *id;
@property(atomic, copy) NSString *name;
@property(atomic, copy) NSString *autoLoginToken;

@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")

- (BOOL)isMyself:(NSString *)userId;
@property(nonatomic, readonly, strong) NSString *headPicUrl;
@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")
@property(atomic, copy) NSString *sid;
@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")
@property(atomic, copy) NSString *topSession;
@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")
@property(atomic, copy) NSString *ecode;
@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")
@property(atomic, assign) BOOL isLogin;
@annotate(FMUser, TBIU_ANN_TRANSIENT: @"1")
@property(atomic, strong) id cookies;
@end