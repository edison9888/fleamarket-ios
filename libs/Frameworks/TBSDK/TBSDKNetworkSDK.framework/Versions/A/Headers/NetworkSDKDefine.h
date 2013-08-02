//
//  Define.h
//  TBSDKNetworkSDK
//
//  Created by 亿刀  iTeam on 13-3-3.
//  Copyright (c) 2013年 亿刀  iTeam. All rights reserved.
//

#ifndef TBSDKNetworkSDK_Define_h
#define TBSDKNetworkSDK_Define_h

#define FUNCTION_LINE [NSString stringWithFormat: @"%s %d", __FUNCTION__, __LINE__]

/** 编译设置
 *  如果以framework的方式引入NetworkSDK，kNetworkSDKIsFramework的定义不起任何作用
 *  如果源码的方式引入NetworkSDK，“TBSDKNetworkSD.h”将将产生条件编译
 */
#define kNetworkSDKIsFramework 0



#endif