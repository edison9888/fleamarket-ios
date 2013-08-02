//
// Created by yuanxiao on 13-6-19.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

// user location
#define FM_SETTING_USER_LATITUDE                 @"userLatitude"
#define FM_SETTING_USER_LONGITUDE                 @"userLongitude"
#define FM_SETTING_USER_PROVINCE                 @"userProvince"
#define FM_SETTING_USER_CITY                      @"userCity"
#define FM_SETTING_USER_AREA                      @"userArea"

#define LS(key) NSLocalizedString(key, @"")

#define KCategoryRootID                           @"50023878"

#define kItemDefaultDescriptionText @"这个卖家太懒了，宝贝描述里面一个字都不肯写。^_^!"

typedef enum {
    FMItemTradeTypeOnline = 0,
    FMItemTradeTypeF2F = 1,
    FMItemTradeTypeAnyway = 2,
} FMItemTradeType;

typedef enum {
    FM_UPLOAD_TYPE_POST = 0,
    FM_UPLOAD_TYPE_COMMENT = 1
} FM_UPLOAD_TYPE;

@interface FMCommon : NSObject

+ (CGFloat)originYByHeight:(CGFloat)frameHeight sizeHeight:(CGFloat)selfHeight;

+ (NSString *)locationStringbyProvince:(NSString *)province
                                  city:(NSString *)cityText
                                  area:(NSString *)areaText
                     bySeperatedString:(NSString *)text;

+ (NSString *)descriptionWithTime:(NSTimeInterval)publishTime;

+ (NSString *)relativeTime:(NSString *)timeString
                serverTime:(NSString *)serverTime;

+ (NSDateFormatter *)postTimeDateFormatter;

+ (NSString *)nowDateTimeString;

+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)alert:(NSString *)title message:(NSString *)message;

+ (void)showToast:(UIView *)parentView text:(NSString *)text;

+ (UIView *)firstResponderView;

+ (void)hideKeyboard;

+ (BOOL)isPrice:(NSString *)value;

+ (BOOL)isDigest:(NSString *)value;

+ (NSString *)emojiKey:(NSString *)key;

+ (NSDictionary *)getEmojiDict;

+ (float)textLength:(NSString *)content;

@end