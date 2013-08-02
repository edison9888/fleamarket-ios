//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-21 上午9:12.
//


#import <Foundation/Foundation.h>


@interface TBIUPreference : NSObject
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

+ (id)preferenceWithUserDefaults:(NSUserDefaults *)userDefaults;

//use [NSUserDefaults standardUserDefaults]
+ (TBIUPreference *)instance;

#pragma mark - 操作
- (void)setPreference:(id)obj ForKey:(NSString *)key;

- (void)setDictionaryPreference:(NSDictionary *)obj ForKey:(NSString *)key;

- (void)asyncSetPreference:(id)obj ForKey:(NSString *)key;

- (void)asyncSetDictionaryPreference:(NSDictionary *)obj ForKey:(NSString *)key;

- (void)removePreferenceByKey:(NSString *)key;

- (void)asyncRemovePreferenceByKey:(NSString *)key;

- (id)preferenceByKey:(NSString *)key;

- (NSDictionary *)dictionaryPreferenceByKey:(NSString *)key;
@end