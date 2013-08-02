//
//  TBSDKEncryptionUntil.h
//  TBSDKNetworkSDK
//
//  Created by 亿刀 iTeam on 13-4-10.
//  Copyright (c) 2013年 亿刀 iTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBSDKEncryptionUntil : NSObject

+ (NSData *)encryptionString:(NSString *)string key:(NSString *)key;

+ (NSString *)decryptWithKey:(NSString *)key decrypDta:(NSData *)data;

@end
