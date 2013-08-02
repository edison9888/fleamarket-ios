//
//  FMPreference.h
//  FleaMarket
//
//  Created by sts taobao on 12-7-25.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FMPreference : NSObject {

}

+ (void)setDiskObject:(id)obj ForKey:(NSString *)key;

+ (void)removeDiskObjectByKey:(NSString *)key;

+ (id)cacheByKey:(NSString *)key;


@end
