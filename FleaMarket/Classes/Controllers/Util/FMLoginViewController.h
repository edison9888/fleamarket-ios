//
//  FMLoginViewController.h
//  FleaMarket
//
//  Created by taobao sts on 12-7-30.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//

#import "FMBaseViewController.h"


typedef void (^FM_LOGIN_CALLBACK)(BOOL isLoginSuccess);

@interface FMLoginViewController : FMBaseViewController <FMNeedClosePanWithSidePanel>

@property(nonatomic, copy) FM_LOGIN_CALLBACK loginCallback;

@end
