//
//  LoginSDK.h
//  LoginSDK
//
//  Created by 亿刀 on 13-4-9.
//  Copyright (c) 2013年 yidao. All rights reserved.
//

#import "TBSDKLoginDefine.h"

#if kLoginSDKIsFramework
#import <LoginSDK/TBSDKLoginEngine.h>
#import <LoginSDK/TBSDKLoginDefine.h>
#import <LoginSDK/TBSDKLoginErrorDefine.h>
#import <LoginSDK/TBSDKLoginConfiguration.h>


#else



#import "TBSDKLoginEngine.h"
#import "TBSDKLoginDefine.h"
#import "TBSDKLoginErrorDefine.h"
#import "TBSDKLoginConfiguration.h"

#endif