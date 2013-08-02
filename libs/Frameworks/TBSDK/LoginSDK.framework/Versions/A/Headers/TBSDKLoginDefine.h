//
//  TBSDKLoginDefine.h
//  TBSDKLoginSDK
//
//  Created by 亿刀 on 13-3-29.
//  Copyright (c) 2013年 亿刀. All rights reserved.
//

#ifndef TBSDKLoginSDK_TBSDKLoginDefine_h
#define TBSDKLoginSDK_TBSDKLoginDefine_h

/****************************************************************************************************/
/** 条件编译
 *  如果TBSDKNetworkSDK是framework方式引入，kNetworkSDKIsFramework定义为 1
 *  如果TBSDKNetworkSDK是源码方式引入，kNetworkSDKIsFramework定义为 0
 */
#define kNetworkSDKUseIsFramework 1

#if kNetworkSDKUseIsFramework

#import <TBSDKNetworkSDK/TBSDKNetworkSDK.h>

#else

#import "TBSDKNetworkSDK.h"

#endif
/****************************************************************************************************/

#define kLoginSDKNotificationLoginSuccess           @"kLoginSDKNotificationLoginSuccess"
#define kLoginSDKNotificationLoginFail              @"kLoginSDKNotificationLoginFail"
#define kLoginSDKNotificationLogout                 @"kNotificationLoginLogout"


//----------------------------------------------------------------------------------------------------//
/** 编译设置
 *  如果以framework的方式引入LoginSDK，kLoginSDKIsFramework的定义不起任何作用
 *  如果源码的方式引入LoginSDK，“LoginSDK.h”将将产生条件编译
 */
#define kLoginSDKIsFramework 0
//----------------------------------------------------------------------------------------------------//


#endif
