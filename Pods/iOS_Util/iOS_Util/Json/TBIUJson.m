//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-5-22 下午1:37.
//


#import "TBIUJson.h"

NSData *TBIUJSONEncode(id object, NSError **error) {
    __autoreleasing NSData *data = nil;

    SEL _JSONKitSelector = NSSelectorFromString(@"JSONDataWithOptions:error:");
    SEL _YAJLSelector = NSSelectorFromString(@"yajl_JSONString");

    id _SBJsonWriterClass = NSClassFromString(@"SBJsonWriter");
    SEL _SBJsonWriterSelector = NSSelectorFromString(@"dataWithObject:");

    id _NXJsonSerializerClass = NSClassFromString(@"NXJsonSerializer");
    SEL _NXJsonSerializerSelector = NSSelectorFromString(@"serialize:");

    id _NSJSONSerializationClass = NSClassFromString(@"NSJSONSerialization");
    SEL _NSJSONSerializationSelector = NSSelectorFromString(@"dataWithJSONObject:options:error:");


    if (_NSJSONSerializationClass && [_NSJSONSerializationClass respondsToSelector:_NSJSONSerializationSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NSJSONSerializationClass methodSignatureForSelector:_NSJSONSerializationSelector]];
        invocation.target = _NSJSONSerializationClass;
        invocation.selector = _NSJSONSerializationSelector;

        [invocation setArgument:&object
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        NSUInteger writeOptions = 0;
        [invocation setArgument:&writeOptions
                        atIndex:3];
        if (error != NULL) {
            [invocation setArgument:error
                            atIndex:4];
        }

        [invocation invoke];
        [invocation getReturnValue:&data];
    } else if (_JSONKitSelector && [object respondsToSelector:_JSONKitSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:_JSONKitSelector]];
        invocation.target = object;
        invocation.selector = _JSONKitSelector;

        NSUInteger serializeOptionFlags = 0;
        [invocation setArgument:&serializeOptionFlags
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        if (error != NULL) {
            [invocation setArgument:error
                            atIndex:3];
        }

        [invocation invoke];
        [invocation getReturnValue:&data];
    } else if (_SBJsonWriterClass && [_SBJsonWriterClass instancesRespondToSelector:_SBJsonWriterSelector]) {
        id writer = [[_SBJsonWriterClass alloc] init];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[writer methodSignatureForSelector:_SBJsonWriterSelector]];
        invocation.target = writer;
        invocation.selector = _SBJsonWriterSelector;

        [invocation setArgument:&object
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation

        [invocation invoke];
        [invocation getReturnValue:&data];
    } else if (_YAJLSelector && [object respondsToSelector:_YAJLSelector]) {
        @try {
            NSString *JSONString = nil;
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:_YAJLSelector]];
            invocation.target = object;
            invocation.selector = _YAJLSelector;

            [invocation invoke];
            [invocation getReturnValue:&JSONString];

            data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            if (error != NULL) {
                *error = [[NSError alloc]
                                   initWithDomain:NSStringFromClass([exception class])
                                             code:0
                                         userInfo:[exception userInfo]];
            }
        }
    } else if (_NXJsonSerializerClass && [_NXJsonSerializerClass respondsToSelector:_NXJsonSerializerSelector]) {
        NSString *JSONString = nil;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NXJsonSerializerClass methodSignatureForSelector:_NXJsonSerializerSelector]];
        invocation.target = _NXJsonSerializerClass;
        invocation.selector = _NXJsonSerializerSelector;

        [invocation setArgument:&object
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation

        [invocation invoke];
        [invocation getReturnValue:&JSONString];
        data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please either target a platform that supports NSJSONSerialization or add one of the following libraries to your project: JSONKit, SBJSON, or YAJL", nil)
                                                             forKey:NSLocalizedRecoverySuggestionErrorKey];
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:NSLocalizedString(@"No JSON generation functionality available", nil)
                               userInfo:userInfo] raise];
    }

    return data;
}

id TBIUJSONDecode(NSData *data, NSError **error) {
    __autoreleasing id JSON = nil;

    SEL _JSONKitSelector = NSSelectorFromString(@"objectFromJSONDataWithParseOptions:error:");
    SEL _YAJLSelector = NSSelectorFromString(@"yajl_JSONWithOptions:error:");

    id _SBJSONParserClass = NSClassFromString(@"SBJsonParser");
    SEL _SBJSONParserSelector = NSSelectorFromString(@"objectWithData:");

    id _NSJSONSerializationClass = NSClassFromString(@"NSJSONSerialization");
    SEL _NSJSONSerializationSelector = NSSelectorFromString(@"JSONObjectWithData:options:error:");

    id _NXJsonParserClass = NSClassFromString(@"NXJsonParser");
    SEL _NXJsonParserSelector = NSSelectorFromString(@"parseData:error:ignoreNulls:");


    if (_NSJSONSerializationClass && [_NSJSONSerializationClass respondsToSelector:_NSJSONSerializationSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NSJSONSerializationClass methodSignatureForSelector:_NSJSONSerializationSelector]];
        invocation.target = _NSJSONSerializationClass;
        invocation.selector = _NSJSONSerializationSelector;

        [invocation setArgument:&data
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        NSUInteger readOptions = 0;
        [invocation setArgument:&readOptions
                        atIndex:3];
        if (error != NULL) {
            [invocation setArgument:&error
                            atIndex:4];
        }

        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_JSONKitSelector && [data respondsToSelector:_JSONKitSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[data methodSignatureForSelector:_JSONKitSelector]];
        invocation.target = data;
        invocation.selector = _JSONKitSelector;

        NSUInteger parseOptionFlags = 0;
        [invocation setArgument:&parseOptionFlags
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        if (error != NULL) {
            [invocation setArgument:&error
                            atIndex:3];
        }

        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_SBJSONParserClass && [_SBJSONParserClass instancesRespondToSelector:_SBJSONParserSelector]) {
        id parser = [[_SBJSONParserClass alloc] init];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[parser methodSignatureForSelector:_SBJSONParserSelector]];
        invocation.target = parser;
        invocation.selector = _SBJSONParserSelector;

        [invocation setArgument:&data
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation

        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_YAJLSelector && [data respondsToSelector:_YAJLSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[data methodSignatureForSelector:_YAJLSelector]];
        invocation.target = data;
        invocation.selector = _YAJLSelector;

        NSUInteger yajlParserOptions = 0;
        [invocation setArgument:&yajlParserOptions
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        if (error != NULL) {
            [invocation setArgument:&error
                            atIndex:3];
        }

        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_NXJsonParserClass && [_NXJsonParserClass respondsToSelector:_NXJsonParserSelector]) {
        NSNumber *nullOption = [NSNumber numberWithBool:YES];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NXJsonParserClass methodSignatureForSelector:_NXJsonParserSelector]];
        invocation.target = _NXJsonParserClass;
        invocation.selector = _NXJsonParserSelector;

        [invocation setArgument:&data
                        atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        if (error != NULL) {
            [invocation setArgument:&error
                            atIndex:3];
        }
        [invocation setArgument:&nullOption
                        atIndex:4];

        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please either target a platform that supports NSJSONSerialization or add one of the following libraries to your project: JSONKit, SBJSON, or YAJL", nil)
                                                             forKey:NSLocalizedRecoverySuggestionErrorKey];
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:NSLocalizedString(@"No JSON parsing functionality available", nil)
                               userInfo:userInfo] raise];
    }

    return JSON;
}
