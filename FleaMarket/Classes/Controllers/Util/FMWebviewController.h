//
//  FMWebViewController.h
//  fleamarket
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 Taobao. All rights reserved.
//

typedef enum {
    FMWebViewTypeRequest,
    FMWebViewTypeHTML
} FMWebViewType;

#import <UIKit/UIKit.h>
#import "FMBaseViewController.h"

@interface FMWebViewController : FMBaseViewController<UIWebViewDelegate, FMNeedLoginProtocol> {
}

@property (nonatomic, assign)BOOL scaled;
@property (nonatomic, assign) BOOL clearCookie;
@property (nonatomic, assign) FMWebViewType webViewType;
@property (nonatomic, copy) NSString *url;

@end
