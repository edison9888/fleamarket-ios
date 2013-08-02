//
//  TBJSONBridge.m
//  TBSDK.Demo
//
//  Created by Robert on 13-1-21.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "JSONKit.h"
//#import "TBSDKJSONBridge.h"

@implementation NSString (TBJSONDeserializing)
- (id)tbObjectFromJSONString
{
    return [self objectFromJSONString];
}

- (id)tbMutableObjectFromJSONString
{
    return [self mutableObjectFromJSONString];
}

@end

@implementation NSData (TBJSONDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)tbObjectFromJSONData
{
    return [self objectFromJSONData];
}

- (id)tbMutableObjectFromJSONData
{
    return [self mutableObjectFromJSONData];
}
@end

////////////
#pragma mark Serializing methods
////////////

@implementation NSString (TBJSONSerializing)
// Convenience methods for those that need to serialize the receiving NSString (i.e., instead of having to serialize a NSArray with a single NSString, you can "serialize to JSON" just the NSString).
// Normally, a string that is serialized to JSON has quotation marks surrounding it, which you may or may not want when serializing a single string, and can be controlled with includeQuotes:
// includeQuotes:YES `a "test"...` -> `"a \"test\"..."`
// includeQuotes:NO  `a "test"...` -> `a \"test\"...`
- (NSData *)tbJSONData
{
    return [self JSONData];
}

- (NSString *)tbJSONString
{
    return [self JSONString];
}

@end

@implementation NSArray (TBJSONSerializing)
- (NSData *)tbJSONData
{
    return [self JSONData];
}

- (NSString *)tbJSONString
{
    return [self JSONString];
}
@end

@implementation NSDictionary (TBJSONSerializing)
- (NSData *)tbJSONData
{
    return [self JSONData];
}

- (NSString *)tbJSONString
{
    return [self JSONString];
}

@end

