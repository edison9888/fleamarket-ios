//
//  TBSDKNetworkSDK.h
//  TBNetwokSDK
//
//  Created by 亿刀 on 13-2-6.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//
#import "NetworkSDKDefine.h"

#if kNetworkSDKIsFramework
#import <TBSDKNetworkSDK/TBSDKConfiguration.h>
#import <TBSDKNetworkSDK/TBSDKErrorResponse.h>
#import <TBSDKNetworkSDK/TBSDKErrorRule.h>
#import <TBSDKNetworkSDK/TBSDKMTOPServer.h>
#import <TBSDKNetworkSDK/TBSDKTOPServer.h>
#import <TBSDKNetworkSDK/TBSDKServer.h>
#import <TBSDKNetworkSDK/TBSDKServerDelegate.h>
#import <TBSDKNetworkSDK/TBSDKServerQueue.h>
#import <TBSDKNetworkSDK/TBSDKErrorHandleDelegate.h>
#import <TBSDKNetworkSDK/TBSDKObject+Category.h>
#import <TBSDKNetworkSDK/MAZeroingWeakRef.h>
#import <TBSDKNetworkSDK/TBSDKConfigurationHelper.h>
#import <TBSDKNetworkSDK/TBSDKJSONBridge.h>
#import <TBSDKNetworkSDK/TBSDKLogUtil.h>
#import <TBSDKNetworkSDK/TBSDKAccountInfo.h>
#import <TBSDKNetworkSDK/TBSDKEncryptionUntil.h>




#else



#import "TBSDKConfiguration.h"
#import "TBSDKErrorResponse.h"
#import "TBSDKErrorRule.h"
#import "TBSDKMTOPServer.h"
#import "TBSDKTOPServer.h"
#import "TBSDKServer.h"
#import "TBSDKServerDelegate.h"
#import "TBSDKServerQueue.h"
#import "TBSDKErrorHandleDelegate.h"
#import "TBSDKObject+Category.h"
#import "MAZeroingWeakRef.h"
#import "TBSDKConfigurationHelper.h"
#import "TBSDKJSONBridge.h"
#import "TBSDKLogUtil.h"
#import "TBSDKAccountInfo.h"
#import "TBSDKEncryptionUntil.h"


#endif

#define TBSDK_VERSION @"2.0.1"