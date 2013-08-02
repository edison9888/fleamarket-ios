//
// Created by yuanxiao on 13-6-19.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBProgressHUD/MBProgressHUD.h>
#import "FMCommon.h"
#import "SREmojiConvertor.h"


@implementation FMCommon {

}

#pragma mark rect
+ (CGFloat)originYByHeight:(CGFloat)frameHeight sizeHeight:(CGFloat)selfHeight {
    CGFloat y = (frameHeight - selfHeight) * 0.5;
    return y;
}

+ (NSString *)locationStringbyProvince:(NSString *)province
                                  city:(NSString *)cityText
                                  area:(NSString *)areaText
                     bySeperatedString:(NSString *)text {
    NSString *retString = nil;
    if (province && (province.length > 0)) {
        retString = [NSString stringWithFormat:@"%@",
                                               province];
    }

    if (cityText && (cityText.length > 0)) {
        if (retString && (retString.length > 0)) {
            retString = [NSString stringWithFormat:@"%@%@%@",
                                                   retString,
                                                   text,
                                                   cityText];
        }
        else {
            retString = [NSString stringWithFormat:@"%@",
                                                   cityText];
        }
    }

    if (areaText && (areaText.length > 0)) {
        if (retString && (retString.length > 0)) {
            retString = [NSString stringWithFormat:@"%@%@%@",
                                                   retString,
                                                   text,
                                                   areaText];
        }
        else {
            retString = [NSString stringWithFormat:@"%@",
                                                   areaText];
        }
    }

    return retString;
}

+ (NSString *)descriptionWithTime:(NSTimeInterval)publishTime {
    NSString *strDate = nil;

    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:publishTime];

    NSTimeInterval interval = 0 - [date timeIntervalSinceNow];

    NSInteger intervalMinis = (NSInteger) (interval / 60);
    if (intervalMinis <= 1) {
        strDate = @"1分钟前";
    } else if (intervalMinis < 60) {
        strDate = [NSString stringWithFormat:@"%d分钟前",
                                             intervalMinis];
    } else {
        NSInteger intervalHour = (NSInteger) (interval / (60 * 60));
        if (intervalHour < 24) {
            strDate = [NSString stringWithFormat:@"%d小时前",
                                                 intervalHour];
        } else {
            NSInteger intervalDay = (NSInteger) (interval / (24 * 60 * 60));
            if (intervalDay <= 29) {
                strDate = [NSString stringWithFormat:@"%d天前",
                                                     intervalDay];
            } else {
                strDate = @"1个月前";
            }
        }
    }
    return strDate;
}

+ (NSString *)relativeTime:(NSString *)timeString
                serverTime:(NSString *)serverTime {
    NSTimeInterval time = 0;
    if (!serverTime) {
        time = [FMCommon postTimeSinceNow:serverTime];
    }
    NSDate *postDate = [[FMCommon postTimeDateFormatter] dateFromString:timeString];
    NSTimeInterval relativeSecond = [postDate timeIntervalSinceReferenceDate] - time;
    return [FMCommon descriptionWithTime:relativeSecond];
}

+ (NSDateFormatter *)postTimeDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return dateFormatter;
}

+ (NSTimeInterval)postTimeSinceNow:(NSString *)serverTime {
    NSDate *serverDate = [[FMCommon postTimeDateFormatter] dateFromString:serverTime];
    NSTimeInterval timeSinceNow = [serverDate timeIntervalSinceNow];
    return timeSinceNow;
}

+ (NSString *)nowDateTimeString {
    NSDate *dateNow = [NSDate date];
    NSDateFormatter *formatter = [FMCommon postTimeDateFormatter];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:dateNow];
}

+ (NSString *)stringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [FMCommon postTimeDateFormatter];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:date];
}

+ (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)showToast:(UIView *)parentView text:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parentView
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES
   afterDelay:1];
}

+ (UIView *)firstResponderView {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponderView = [keyWindow performSelector:@selector(firstResponder)];
    return firstResponderView;
}

+ (void)hideKeyboard {
    UIView *firstResponderView = [FMCommon firstResponderView];
    [firstResponderView resignFirstResponder];
}

+ (BOOL)isPrice:(NSString *)value {
    BOOL ret = NO;
    NSString *regex = @"^\\d{0,8}\\.{0,1}(\\d{1,2})?$";
    if (nil != value) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                                                                  regex];
        ret = [predicate evaluateWithObject:value];
    }

    return ret;
}

+ (BOOL)isDigest:(NSString *)value {
    BOOL ret = NO;
    NSString *regex = @"^[0-9]{1}[0-9\\.]*";
    if (nil != value) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        ret = [predicate evaluateWithObject:value];
    }

    return ret;
}

+ (NSString *)emojiKey:(NSString *)key {
    id aKey = [[self getEmojiDict] objectForKey:key];
    return [[[SREmojiConvertor instance] emoji4To5Dict] objectForKey:aKey];
}

+ (NSDictionary *)getEmojiDict {
    static NSDictionary *emojiDict = nil;
    @synchronized (self) {
        if (!emojiDict) {
            emojiDict = [NSDictionary dictionaryWithObjectsAndKeys:@"\ue056", @"/:^_^",
                                                                   @"\ue414", @"/:^$^",
                                                                   @"\ue105", @"/:Q",
                                                                   @"\ue415", @"/:815",
                                                                   @"\ue418", @"/:809",
                                                                   @"\ue057", @"/:^O^",
                                                                   @"\ue057", @"/:081",
                                                                   @"\ue418", @"/:087",
                                                                   @"\ue31e", @"/:086",
                                                                   @"\ue422", @"/:H",
                                                                   @"\ue056", @"/:012",
                                                                   @"\ue011", @"/:806",
                                                                   @"\ue00e", @"/:b",
                                                                   @"\ue003", @"/:^x^",
                                                                   @"\ue106", @"/:814",
                                                                   @"\ue402", @"/:^W^",
                                                                   @"\ue105", @"/:080",
                                                                   @"\ue142", @"/:066",
                                                                   @"\ue104", @"/:807",
                                                                   @"\ue12f", @"/:805",
                                                                   @"\ue10f", @"/:071",
                                                                   @"\ue409", @"/:072",
                                                                   @"\ue04e", @"/:065",
                                                                   @"\ue41e", @"/:804",
                                                                   @"\ue057", @"/:813",
                                                                   @"\ue417", @"/:818",
                                                                   @"\ue106", @"/:015",
                                                                   @"\ue40b", @"/:084",
                                                                   @"\ue402", @"/:801",
                                                                   @"\ue407", @"/:811",
                                                                   @"\ue020", @"/:?",
                                                                   @"\ue424", @"/:077",
                                                                   @"\ue424", @"/:083",
                                                                   @"\ue059", @"/:817",
                                                                   @"\ue40c", @"/:!",
                                                                   @"\ue231\ue230", @"/:068",
                                                                   @"\ue40a", @"/:079",
                                                                   @"\ue40c", @"/:028",
                                                                   @"\ue403", @"/:026",
                                                                   @"\ue108", @"/:007",
                                                                   @"\ue413", @"/:816",
                                                                   @"\ue108", @"/:'\"\"",
                                                                   @"\ue40f", @"/:802",
                                                                   @"\ue330", @"/:027",
                                                                   @"\ue13c", @"/:(Zz...)",
                                                                   @"\ue410", @"/:*&*",
                                                                   @"\ue10c", @"/:810",
                                                                   @"\ue406", @"/:>_<",
                                                                   @"\ue412", @"/:018",
                                                                   @"\ue411", @"/:>O<",
                                                                   @"\ue412", @"/:020",
                                                                   @"\ue40b", @"/:044",
                                                                   @"\ue10c", @"/:819",
                                                                   @"\ue40d", @"/:085",
                                                                   @"\ue40d", @"/:812",
                                                                   @"\ue058", @"/:\"",
                                                                   @"\ue10c", @"/:>M<",
                                                                   @"\ue10c", @"/:>@<",
                                                                   @"\ue11a", @"/:076",
                                                                   @"\ue40d", @"/:069",
                                                                   @"\ue40d", @"/:O",
                                                                   @"\ue40c", @"/:067",
                                                                   @"\ue00d", @"/:043",
                                                                   @"\ue22f", @"/:P",
                                                                   @"\ue107", @"/:808",
                                                                   @"\ue416", @"/:>W<",
                                                                   @"\ue448", @"/:073",
                                                                   @"\ue51e", @"/:008",
                                                                   @"\ue41d", @"/:803",
                                                                   @"\ue427", @"/:074",
                                                                   @"\ue10c", @"/:O=O",
                                                                   @"\ue10c", @"/:036",
                                                                   @"\ue421", @"/:039",
                                                                   @"\ue152", @"/:045",
                                                                   @"\ue152", @"/:046",
                                                                   @"\ue05a", @"/:048",
                                                                   @"\ue10c", @"/:047",
                                                                   @"\ue002", @"/:girl",
                                                                   @"\ue001", @"/:man",
                                                                   @"\ue04f", @"/:052",
                                                                   @"\ue420", @"/:(OK)",
                                                                   @"\ue41f", @"/:8*8",
                                                                   @"\ue41d", @"/:)-(",
                                                                   @"\ue41c", @"/:lip",
                                                                   @"\ue032", @"/:-F",
                                                                   @"\ue119", @"/:-W",
                                                                   @"\ue327", @"/:Y",
                                                                   @"\ue023", @"/:qp ",
                                                                   @"\ue12f", @"/:$",
                                                                   @"\ue11e", @"/:%",
                                                                   @"\ue437", @"/:(&)",
                                                                   @"\ue103", @"/:@",
                                                                   @"\ue00a", @"/:~B",
                                                                   @"\ue044", @"/:U*U",
                                                                   @"\ue024", @"/:clock",
                                                                   @"\ue536", @"/:R",
                                                                   @"\ue04c", @"/:C",
                                                                   @"\ue01d", @"/:plane",
                                                                   @"\ue029", @"/:075",
                                                                   nil];
        }
    }
    return emojiDict;
}

+ (float)textLength:(NSString *)content {
    float len = 0.f;
    for (NSUInteger i = 0; i < [content length]; i++) {
        unichar c = [content characterAtIndex:i];
        if (isalnum(c) || isspace(c)) {
            len += 0.5;
        } else {
            len += 1.0;
        }
    }

    return len;
}

@end