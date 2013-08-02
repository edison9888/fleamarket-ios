//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-12 下午2:39.
//


#import <Foundation/Foundation.h>

@class FMUser;
@class FMSetting;
@class FMLocation;
@class FMLastPostInfo;


@interface FMCacheObject : NSObject
@property(nonatomic, strong) FMUser *user;
@property(nonatomic, strong) FMSetting *setting;
@property(nonatomic, strong) FMLocation *location;
@property(nonatomic, strong) FMLastPostInfo *lastPostInfo;
@property(nonatomic, strong) NSMutableDictionary *postQueues;
@end