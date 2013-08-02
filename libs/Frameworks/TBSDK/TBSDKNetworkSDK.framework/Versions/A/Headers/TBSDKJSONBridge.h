//
//  TBJSONBridge.h
//  TBSDK.Demo
//
//  Created by Robert on 13-1-21.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>


////////////
#pragma mark Deserializing methods
////////////
@interface NSString (TBJSONDeserializing)
- (id)tbObjectFromJSONString;
- (id)tbMutableObjectFromJSONString;
@end

@interface NSData (TBJSONDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)tbObjectFromJSONData;
- (id)tbMutableObjectFromJSONData;
@end

////////////
#pragma mark Serializing methods
////////////

@interface NSString (TBJSONSerializing)
// Convenience methods for those that need to serialize the receiving NSString (i.e., instead of having to serialize a NSArray with a single NSString, you can "serialize to JSON" just the NSString).
// Normally, a string that is serialized to JSON has quotation marks surrounding it, which you may or may not want when serializing a single string, and can be controlled with includeQuotes:
// includeQuotes:YES `a "test"...` -> `"a \"test\"..."`
// includeQuotes:NO  `a "test"...` -> `a \"test\"...`
- (NSData *)tbJSONData;     // Invokes JSONDataWithOptions:JKSerializeOptionNone   includeQuotes:YES
- (NSString *)tbJSONString; // Invokes JSONStringWithOptions:JKSerializeOptionNone includeQuotes:YES
@end

@interface NSArray (TBJSONSerializing)
- (NSData *)tbJSONData;
- (NSString *)tbJSONString;
@end

@interface NSDictionary (TBJSONSerializing)
- (NSData *)tbJSONData;
- (NSString *)tbJSONString;
@end

@interface NSNumber (TBJSONSerializing)
- (NSData *)tbJSONData;
- (NSString *)tbJSONString;
@end
