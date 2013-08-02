//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-16 下午1:16.
//

#import "FMPostRet.h"
#import "NSString+Helper.h"

@implementation FMPostRet {

@private
    NSNumber *_itemId;
    NSString *_shareText;
    BOOL _disableEdit;
}

@synthesize itemId = _itemId;
@synthesize shareText = _shareText;
@synthesize disableEdit = _disableEdit;

- (BOOL)hasShareText {
    return [_shareText isNotBlank];
}


@end