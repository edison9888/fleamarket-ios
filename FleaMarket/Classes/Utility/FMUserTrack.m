//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 下午1:00.
//


#import <UserTrack/UT.h>
#import "FMUserTrack.h"


@implementation FMUserTrack {

}
+ (void)ctrlClicked:(NSString *)controlName onPage:(NSObject *)page {
    [UT pageEnter:page];
    [UT ctrlClicked:controlName];
    [UT pageLeave:page];
}

+ (void)ctrlClicked:(NSString *)controlName {
    [UT ctrlClicked:controlName];
}

@end