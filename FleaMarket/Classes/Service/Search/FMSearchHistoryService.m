// 
// Created by henson on 12/3/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#define kFMSearchKeywordHistoryArray @"keyword_search_history_array"
#define kFMSearchKeywordHistorySet @"keyword_search_history_set"
#define kMaxSearchKeywordCount (20)

#import "FMSearchHistoryService.h"
#import "FMPreference.h"
#import "NSString+Helper.h"

@implementation FMSearchHistoryService {
@private
    NSMutableArray *_keywordArray;
    NSMutableSet *_keywordSet;
}

+ (FMSearchHistoryService *)instance {
    static FMSearchHistoryService *_instance = nil;
    static dispatch_once_t _oncePredicate_FMSearchHistoryService;

    dispatch_once(&_oncePredicate_FMSearchHistoryService, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (NSArray *)getAllSearchHistories {
    NSArray *keywords = [NSArray arrayWithArray:[self _getCachedKeywordArray]];
    return [self reverse:keywords];
}

- (void)addSearchHistory:(NSString *)keyword {
    if ([keyword isBlank]) {
        return;
    }

    NSMutableArray *keywordArray = [self _getCachedKeywordArray];
    NSMutableSet *keywordSet = [self _getCachedKeywordSet];

    if (keywordArray.count == kMaxSearchKeywordCount) {
        NSString *removedKeyword = [keywordArray objectAtIndex:0];
        [keywordSet removeObject:removedKeyword];
        [keywordArray removeObjectAtIndex:0];
    }

    if ([keywordSet containsObject:keyword]) {
        [keywordArray removeObject:keyword];
    } else {
        [keywordSet addObject:keyword];
    }
    [keywordArray addObject:keyword];
    [self saveToDisk:keywordArray
          keywordSet:keywordSet];
}

- (void)deleteSearchHistory:(NSUInteger)index __unused {
    if ([[self getAllSearchHistories] count] < 1) {
        return;
    }
    NSMutableArray *keywordArray = [self _getCachedKeywordArray];
    NSMutableSet *keywordSet = [self _getCachedKeywordSet];
    NSString *keyword = [keywordArray objectAtIndex:index];
    [keywordSet removeObject:keyword];
    [keywordArray removeObjectAtIndex:index];

    [self saveToDisk:keywordArray
          keywordSet:keywordSet];
}

- (void)removeAllSearchHistories {
    if ([[self getAllSearchHistories] count] < 1) {
        return;
    }

    NSMutableArray *keywordArray = [self _getCachedKeywordArray];
    NSMutableSet *keywordSet = [self _getCachedKeywordSet];
    [keywordArray removeAllObjects];
    [keywordSet removeAllObjects];
    [self saveToDisk:keywordArray
          keywordSet:keywordSet];
}

- (void)saveToDisk:(NSMutableArray *)keywordArray keywordSet:(NSMutableSet *)keywordSet {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [FMPreference setDiskObject:keywordArray
                             ForKey:kFMSearchKeywordHistoryArray];
        [FMPreference setDiskObject:keywordSet
                             ForKey:kFMSearchKeywordHistorySet];
    }
    );
}

- (NSMutableArray *)_getCachedKeywordArray {
    @synchronized (self) {
        if (!_keywordArray) {
            NSArray *array = (id) [FMPreference cacheByKey:kFMSearchKeywordHistoryArray];
            _keywordArray = [NSMutableArray arrayWithArray:array];
        }
    }
    return _keywordArray;
}

- (NSMutableSet *)_getCachedKeywordSet {
    @synchronized (self) {
        if (!_keywordSet) {
            NSSet *set = (id) [FMPreference cacheByKey:kFMSearchKeywordHistorySet];
            _keywordSet = [NSMutableSet setWithSet:set];
        }
    }
    return _keywordSet;
}

- (NSArray *)reverse:(NSArray *)array {
    NSMutableArray *_array = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    for (id element in enumerator) {
        [_array addObject:element];
    }
    return _array;
}

@end