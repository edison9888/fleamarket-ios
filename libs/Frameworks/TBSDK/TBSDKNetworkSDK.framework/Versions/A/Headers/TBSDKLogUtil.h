//
//  TBSDKPushCenterLogUtil.h
//  PushCenterSDK
//
//  Created by 亿刀 on 13-3-25.
//  Copyright (c) 2013年 yidao. All rights reserved.
//


#ifdef __cplusplus
extern "C" {
#endif
    
#import <Foundation/Foundation.h>
    
    /** 开关openSDK的log */
    void openSDKSwitchLog(BOOL logCtr);
    
    /** 打印log */
    void openSDKNSLog(NSString *formate, ...);
    
#ifdef __cplusplus
}
#endif