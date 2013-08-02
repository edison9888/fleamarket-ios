//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-5-22 下午1:37.
//


#import <Foundation/Foundation.h>

extern NSData *TBIUJSONEncode(id object, NSError **error);

extern id TBIUJSONDecode(NSData *data, NSError **error);