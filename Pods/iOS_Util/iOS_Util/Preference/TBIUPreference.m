//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-21 上午9:12.
//


#import "TBIUPreference.h"
#import "NSObject+TBIU_ToNSDictionary.h"


@implementation TBIUPreference {
@private
    NSUserDefaults *_userDefaults;

}
+ (TBIUPreference *)instance {
    static TBIUPreference *_instance = nil;
    static dispatch_once_t _oncePredicate_TBIUPreference;

    dispatch_once(&_oncePredicate_TBIUPreference, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (void)_init:(NSUserDefaults *)userDefaults {
    _userDefaults = userDefaults;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _init:[NSUserDefaults standardUserDefaults]];
    }
    return self;
}


- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    self = [super init];
    if (self) {
        [self _init:userDefaults];
    }

    return self;
}

+ (id)preferenceWithUserDefaults:(NSUserDefaults *)userDefaults {
    return [[self alloc] initWithUserDefaults:userDefaults];
}


- (void)setPreference:(id)obj ForKey:(NSString *)key {
    NSUserDefaults *handler = _userDefaults;
    if (nil != obj && nil != key && 0 < [key length]) {
        [handler setObject:[NSKeyedArchiver archivedDataWithRootObject:obj]
                    forKey:key];
    }
    [handler synchronize];
}

- (void)setDictionaryPreference:(id)obj ForKey:(NSString *)key {
    NSUserDefaults *handler = _userDefaults;
    if (nil != obj && nil != key && 0 < [key length]) {
        NSDictionary *dic = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            dic = obj;
        } else {
            dic = [obj toDictionaryOrArray];
        }
        [handler setObject:dic
                    forKey:key];
    }
    [handler synchronize];
}

- (void)asyncSetPreference:(id)obj ForKey:(NSString *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self setPreference:obj
                     ForKey:key];
    }
    );
}

- (void)asyncSetDictionaryPreference:(id)obj ForKey:(NSString *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self setDictionaryPreference:obj
                               ForKey:key];
    }
    );
}


- (void)removePreferenceByKey:(NSString *)key {
    NSUserDefaults *handler = _userDefaults;
    [handler removeObjectForKey:key];
    [handler synchronize];
}

- (void)asyncRemovePreferenceByKey:(NSString *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self asyncRemovePreferenceByKey:key];
    }
    );
}

- (id)preferenceByKey:(NSString *)key {
    NSUserDefaults *handler = _userDefaults;
    if (nil != key && 0 < [key length] && nil != [handler objectForKey:key]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:[handler dataForKey:key]];
    }

    return nil;
}

- (NSDictionary *)dictionaryPreferenceByKey:(NSString *)key {
    NSUserDefaults *handler = _userDefaults;
    if (nil != key && 0 < [key length] && nil != [handler objectForKey:key]) {
        return [handler dictionaryForKey:key];
    }

    return nil;
}

@end