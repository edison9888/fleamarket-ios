//
//  FMPreference.m
//  FleaMarket
//
//  Created by sts taobao on 12-7-25.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//

#import "FMPreference.h"
#import "TBIUPreference.h"

@implementation FMPreference

+ (void)setDiskObject:(id)obj ForKey:(NSString *)key {
    [[TBIUPreference instance]
                     setPreference:obj
                            ForKey:key];
}

+ (void)removeDiskObjectByKey:(NSString *)key {
    [[TBIUPreference instance]
                     removePreferenceByKey:key];
}


+ (id)cacheByKey:(NSString *)key {
    return [[TBIUPreference instance] preferenceByKey:key];
}


@end
