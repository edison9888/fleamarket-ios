//
//  TBSDKServerDelegate.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-1-29.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//
//

@class TBSDKServer;

@protocol TBSDKServerDelegate <NSObject>

@optional

- (void)requestStarted:(TBSDKServer *)server;
- (void)requestSuccess:(TBSDKServer *)server;
- (void)requestFailed:(TBSDKServer *)server;

@end
