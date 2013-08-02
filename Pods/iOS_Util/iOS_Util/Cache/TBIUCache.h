//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-16 下午6:52.
//


#import <Foundation/Foundation.h>
#import "TBIUCommon.h"

@protocol TBIUCache;

enum TBIUCacheType {
    TBIUCacheTypeNone = 0,
    TBIUCacheTypeDisk,
    TBIUCacheTypeMemory,
    TBIUCacheTypeDelegate
};
typedef enum TBIUCacheType TBIUCacheType;


@interface TBIUCache : NSObject
/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property(assign, nonatomic) NSInteger maxCacheAge;

@property(TBIUPropertyWeak, nonatomic) id <TBIUCache> delegate;


+ (TBIUCache *)instance;

- (id)initWithNamespace:(NSString *)ns AndIoQueue:(dispatch_queue_t)queue;

#pragma mark - 清除缓存
- (void)clearMemory;

- (void)clearDisk;

- (void)cleanDisk;

- (unsigned long long)getSize;

- (int)getDiskCount;

#pragma mark -cache 方法

- (void)storeData:(NSData *)data forKey:(NSString *)key;

- (void)storeData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk;

- (NSData *)dataFromMemoryCacheForKey:(NSString *)key;

- (void)dataFromCacheForKey:(NSString *)key done:(void (^)(NSData *data, TBIUCacheType cacheType))doneBlock;

- (void)removeImageForKey:(NSString *)key;

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk;
@end

//缓存没有时 调用此接口取数据
@protocol TBIUCache <NSObject>
@optional
- (void)cache:(TBIUCache *)cache getDatawithKey:(NSString *)key AndWhenDone:(void (^)(NSData *data))doneBlock;

@end