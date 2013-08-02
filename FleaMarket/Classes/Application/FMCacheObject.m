//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-12 下午2:39.
//


#import "FMCacheObject.h"
#import "FMUser.h"
#import "FMSetting.h"
#import "FMLocation.h"
#import "FMLastPostInfo.h"


@implementation FMCacheObject {

@private
    FMUser *_user;
    FMSetting *_setting;
    FMLocation *_location;
    FMLastPostInfo *_lastPostInfo;
    NSMutableDictionary *_postQueues;
}
@synthesize user = _user;
@synthesize setting = _setting;
@synthesize location = _location;
@synthesize lastPostInfo = _lastPostInfo;
@synthesize postQueues = _postQueues;
@end