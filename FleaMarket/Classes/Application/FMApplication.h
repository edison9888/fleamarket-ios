//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午11:32.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <iOS_Util/TBIULocationManager.h>

@class FMUser;
@class FMSetting;
@class FMLocation;
@class FMLastPostInfo;

@interface FMApplication : NSObject
@property(atomic, weak) UIViewController *currentViewController;

@property(atomic, strong, readonly) FMUser *loginUser;
@property(atomic, strong, readonly) FMSetting *setting;
@property(atomic, strong, readonly) FMLocation *location;
@property(atomic, strong, readonly) FMLastPostInfo *lastPostInfo;
@property(atomic, strong, readonly) NSMutableDictionary *postQueues;

+ (FMApplication *)instance;

- (void)systemInit;

- (void)destroy;

- (void)applicationDidStart:(NSDictionary *)launchOptions;

//持久化配置
- (void)saveToPreference;

//异步保存内容
- (void)asyncSaveToPreference;

- (void)autoUpdate;

//更新位置
- (void)updateLocation;

- (void)updateLocationWithBlock:(TBIULocationManagerLocationUpdateBlock)block
                     errorBlock:(TBIULocationManagerLocationUpdateFailBlock)errorBlock;

//清理磁盘缓存
- (void)cleanDiskCache;

- (unsigned long long)getDiskCacheCount;
@end