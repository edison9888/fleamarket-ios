//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-27 上午10:16.
//


#import "FMUserDO.h"


@implementation FMUserDO {

@private
    long _userId;
    NSString *_userNick;
    NSString *_idleSellingNum;
    NSString *_idleBuyNum;
    NSString *_idleSoldNum;
    NSNumber *_idleFavNum;
}
@synthesize userId = _userId;
@synthesize userNick = _userNick;
@synthesize idleSellingNum = _idleSellingNum;
@synthesize idleBuyNum = _idleBuyNum;
@synthesize idleSoldNum = _idleSoldNum;


@synthesize idleFavNum = _idleFavNum;
@end