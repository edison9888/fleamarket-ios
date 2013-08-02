//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-16 下午6:52.
//

#import <UIKit/UIKit.h>
#import "TBIUCache.h"
#import <CommonCrypto/CommonDigest.h>

static const NSInteger kTBIUDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@interface TBIUCache ()
@property(strong, nonatomic) NSCache *memCache;
@property(strong, nonatomic) NSString *diskCachePath;
@property(nonatomic) dispatch_queue_t ioQueue;

@end


@implementation TBIUCache {

@private
    NSInteger _maxCacheAge;
    NSCache *_memCache;
    NSString *_diskCachePath;
    dispatch_queue_t _ioQueue;
}
@synthesize maxCacheAge = _maxCacheAge;
@synthesize memCache = _memCache;
@synthesize diskCachePath = _diskCachePath;
@synthesize ioQueue = _ioQueue;

+ (TBIUCache *)instance {
    static TBIUCache *_instance = nil;
    static dispatch_once_t _oncePredicate_TBIUCache;

    dispatch_once(&_oncePredicate_TBIUCache, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (id)init {
    return [self initWithNamespace:@"default"
                        AndIoQueue:NULL];
}

- (id)initWithNamespace:(NSString *)ns AndIoQueue:(dispatch_queue_t)queue {
    if ((self = [super init])) {
        NSString *fullNamespace = [@"com.taobao.TBIUCache." stringByAppendingString:ns];

        // Create IO serial queue
        if (queue != NULL) {
            _ioQueue = queue;
        } else {
            _ioQueue = dispatch_queue_create("com.taobao.TBIUCache", DISPATCH_QUEUE_SERIAL);
        }
        _maxCacheAge = kTBIUDefaultCacheMaxCacheAge;
        _memCache = [[NSCache alloc] init];
        _memCache.name = fullNamespace;

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];

#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
#endif

    }
    return self;
}

#pragma mark - 清除缓存
- (void)clearMemory {
    [self.memCache removeAllObjects];
}

- (void)clearDisk {
    dispatch_async(self.ioQueue, ^{
        NSFileManager *manager = [[NSFileManager alloc] init];
        [manager removeItemAtPath:self.diskCachePath
                            error:nil];
        [manager createDirectoryAtPath:self.diskCachePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:NULL];
    }
    );
}

- (void)cleanDisk {
    NSString *path = self.diskCachePath;
    dispatch_async(self.ioQueue, ^{
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        // convert NSString path to NSURL path
        NSURL *diskCacheURL = [NSURL fileURLWithPath:path
                                         isDirectory:YES];
        // build an enumerator by also prefetching file properties we want to read
        NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentModificationDateKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
        for (NSURL *fileURL in fileEnumerator) {
            // skip folder
            NSNumber *isDirectory;
            [fileURL getResourceValue:&isDirectory
                               forKey:NSURLIsDirectoryKey
                                error:NULL];
            if ([isDirectory boolValue]) {
                continue;
            }

            // compare file date with the max age
            NSDate *fileModificationDate;
            [fileURL getResourceValue:&fileModificationDate
                               forKey:NSURLContentModificationDateKey
                                error:NULL];
            if ([[fileModificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [manager removeItemAtURL:fileURL
                                   error:nil];
            }
        }
    }
    );
}

- (unsigned long long)getSize {
    unsigned long long size = 0;
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [manager attributesOfItemAtPath:filePath
                                                        error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (int)getDiskCount {
    int count = 0;
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator) {
        count += 1;
    }

    return count;
}


#pragma mark SDImageCache (private)

- (NSString *)cachePathForKey:(NSString *)key {
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG) strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                                    r[0],
                                                    r[1],
                                                    r[2],
                                                    r[3],
                                                    r[4],
                                                    r[5],
                                                    r[6],
                                                    r[7],
                                                    r[8],
                                                    r[9],
                                                    r[10],
                                                    r[11],
                                                    r[12],
                                                    r[13],
                                                    r[14],
                                                    r[15]];

    return [self.diskCachePath stringByAppendingPathComponent:filename];
}


- (void)storeData:(NSData *)data forKey:(NSString *)key {
    [self storeData:data
             forKey:key
             toDisk:YES];
}


- (void)storeData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk {
    if (!data || !key) {
        return;
    }

    [self.memCache setObject:data
                      forKey:key
                        cost:[data length]];

    if (toDisk) {
        NSString *path = self.diskCachePath;
        dispatch_async(self.ioQueue, ^{
            if (data) {
                // Can't use defaultManager another thread
                NSFileManager *fileManager = [[NSFileManager alloc] init];

                if (![fileManager fileExistsAtPath:path]) {
                    [fileManager createDirectoryAtPath:path
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:NULL];
                }

                [fileManager createFileAtPath:[self cachePathForKey:key]
                                     contents:data
                                   attributes:nil];
            }
        }
        );
    }
}

#pragma mark  - 取出缓存

- (NSData *)dataFromMemoryCacheForKey:(NSString *)key {
    return [self.memCache objectForKey:key];
}


- (void)dataFromCacheForKey:(NSString *)key done:(void (^)(NSData *data, TBIUCacheType cacheType))doneBlock {
    if (!doneBlock) return;

    if (!key) {
        doneBlock(nil, TBIUCacheTypeNone);
        return;
    }

    NSData *data = [self dataFromMemoryCacheForKey:key];
    if (data) {
        doneBlock(data, TBIUCacheTypeMemory);
        return;
    }

    NSString *filePath = [self cachePathForKey:key];
    TBIURunInCurrent *currentContext = [[TBIURunInCurrent alloc] init];
    dispatch_async(self.ioQueue, ^{
        NSData *d = [NSData dataWithContentsOfFile:filePath];
        if (d) {
            [self storeData:d
                     forKey:key
                     toDisk:NO];

            [currentContext run:^{
                doneBlock(d, TBIUCacheTypeDisk);
            }];
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(cache:getDatawithKey:AndWhenDone:)]) {
            [currentContext run:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(cache:getDatawithKey:AndWhenDone:)]) {
                    [self.delegate cache:self
                          getDatawithKey:key
                             AndWhenDone:^(NSData *_data) {
                                 if (_data) {
                                     [self storeData:_data
                                              forKey:key
                                              toDisk:YES];
                                 }
                                 [currentContext run:^{
                                     doneBlock(_data, TBIUCacheTypeDelegate);
                                 }];
                             }];
                }
            }];
        }
    }
    );
}

- (void)removeImageForKey:(NSString *)key {
    [self removeImageForKey:key
                   fromDisk:YES];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk {
    if (key == nil) {
        return;
    }

    [self.memCache removeObjectForKey:key];

    if (fromDisk) {
        dispatch_async(self.ioQueue, ^{
            [[[NSFileManager alloc]
                             init]
                             removeItemAtPath:[self cachePathForKey:key]
                                        error:nil];
        }
        );
    }
}

@end