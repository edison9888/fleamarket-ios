// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemCommentDO.h"
#import "FMCommon.h"
#import "SREmojiConvertor.h"
#import "NSString+Helper.h"

@implementation FMItemCommentDOList {

}
@end

@implementation FMItemCommentDO {

}
- (NSString *)contentWithEmoji {
    if (self.content && [self.content containsString:@"/:"]) {
        NSString *s = [self.content copy];
        NSDictionary *dict = [FMCommon getEmojiDict];
        for (NSString *key in [dict allKeys]) {
            id aKey = [dict objectForKey:key];
            if (aKey) {
                NSString *replacement = [[[SREmojiConvertor instance] emoji4To5Dict]
                                                            objectForKey:aKey];
                if (replacement)
                    s = [s stringByReplacingOccurrencesOfString:key
                                                     withString:replacement];
            }
        }
        return s;
    }
    return self.content;
}

- (BOOL)voiceIsEmpty {
    if (!self.voiceUrl || [self.voiceUrl isBlank]) {
        return YES;
    }
    return NO;
}

@end