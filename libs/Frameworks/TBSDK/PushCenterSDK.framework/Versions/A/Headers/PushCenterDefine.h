//
//  Define.h
//  PushCenterDemo
//
//  Created by 亿刀 pushsdk_version 1.1  iTeam on 13-3-3.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#ifndef PushCenterDemo_Define_h
#define PushCenterDemo_Define_h

//#define FUNCTION_LINE [NSString stringWithFormat: @"%s %d", __FUNCTION__, __LINE__]

//----------------------------------------消息名称-----------------------------------------------------//

#define kPushCenterNewSummaryNotification @"PushCenter New Summary Notification"
#define kPushCenterGetDetailNotification  @"PushCenter Get Detail Notification"

//---------------------------------------------------------------------------------------------------//



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


//----------------------------------------------------------------------------------------------------//
/** 编译设置
 *  如果以framework的方式引入PushCenterSDK，kPushCenterSDKIsFramework的定义不起任何作用
 *  如果源码的方式引入NetworkSDK，“TBSDkPushCenterSDK.h”将将产生条件编译
 */
#define kPushCenterSDKIsFramework 0
//----------------------------------------------------------------------------------------------------//


#endif
