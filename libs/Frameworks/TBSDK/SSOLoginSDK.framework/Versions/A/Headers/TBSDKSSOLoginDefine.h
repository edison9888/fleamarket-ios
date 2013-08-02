//
//  TBSDKSSOLoginDefine.h
//  LoginSDKDemo
//
//  Created by 亿刀 on 13-4-18.
//  Copyright (c) 2013年 yidao. All rights reserved.
//

#ifndef LoginSDKDemo_TBSDKSSOLoginDefine_h
#define LoginSDKDemo_TBSDKSSOLoginDefine_h

#define kSSOSDKAccountNameKey               @"kSSOSDKAccountNameKey"
#define kSSOSDKSSOTokenKey                  @"kSSOSDKSSOTokenKey"
#define kSSOSDKSSOtTokenInvalidDateKey      @"kSSOSDKSSOtTokenInvalidDateKey"
#define kSSOSDKSSOLoginSDKVersionKey        @"kSSOSDKSSOLoginSDKVersionKey"
#define kSSOSDKSSOLoginAppInfoArrayKey      @"kSSOSDKSSOLoginSDKVersionDateKey"

#define kSSOSDKAppNameKey                   @"kSSOSDKAppNameKey"
#define kSSOSDKAppVersionKey                @"kSSOSDKAppVersionKey"
#define kSSOSDKSSOLoginDateKey              @"kSSOSDKSSOLoginDateKey"
#define kSSOSDKAppIconImageKey              @"kSSOSDKAppIconImageKey"
#define kSSOSDKBundleIdKey                  @"kSSOSDKBundleIdKey"

#define kSSOSDKErrorNoHaveSSOTokenErrorCode @"kSSOSDKErrorNoHaveSSOToken"
#define kSSOSDKErrorNoHaveSSOTokenErrorMSG  @"没有可使用的SSOToken"

/****************************************************************************************************/
/** 条件编译
 *  如果TBSDKNetworkSDK是framework方式引入，kNetworkSDKIsFramework定义为 1
 *  如果TBSDKNetworkSDK是源码方式引入，kNetworkSDKIsFramework定义为 0
 */
#define kSSOLoginSDKNetworkSDKUseIsFramework 1

#if kSSOLoginSDKNetworkSDKUseIsFramework

#import <TBSDKNetworkSDK/TBSDKNetworkSDK.h>

#else

#import "TBSDKNetworkSDK.h"

#endif
/****************************************************************************************************/


//----------------------------------------------------------------------------------------------------//
/** 编译设置
 *  如果以framework的方式引入SSOLoginSDK，kSSOLoginSDKIsFramework的定义不起任何作用
 *  如果源码的方式引入SSOLoginSDK，“LoginSDK.h”将将产生条件编译
 */
#define kSSOLoginSDKIsFramework 0
//----------------------------------------------------------------------------------------------------//


#endif