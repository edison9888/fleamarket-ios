//
// Created by yuanxiao on 13-5-28.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareWeChatModel.h"


@implementation TBSocialShareWeChatModel {

@private
    TBSocialWXMessageType _messageType;
    NSString *_appUrl;
    UIImage *_thumbImage;
    id _wxMediaObject;
    NSString *_extInfo;
    NSString *_webUrl;
}
@synthesize messageType = _messageType;
@synthesize appUrl = _appUrl;
@synthesize thumbImage = _thumbImage;
@synthesize wxMediaObject = _wxMediaObject;
@synthesize extInfo = _extInfo;
@synthesize webUrl = _webUrl;
@end