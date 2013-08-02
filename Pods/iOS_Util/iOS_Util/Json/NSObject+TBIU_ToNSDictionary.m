//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午12:09.
//


#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+TBIU_ToNSDictionary.h"
#import "TBIUConvertDefine.h"

@interface NSDictionary (Private)

- (void)getPropertyToDictionary:(NSMutableDictionary *)dictionary pProperty:(objc_property_t)property withDepth:
        (NSUInteger)depth;
@end


@implementation NSObject (TBIU_ToNSDictionary)
- (id)toDictionaryOrArray {
    return [self toDictionaryOrArrayWithDepth:8];
}


- (id)toDictionaryOrArrayWithDepth:(NSUInteger)depth {
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]]) {
        id selfObj = self;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[selfObj count]];
        if (depth > 0) {
            for (id o in selfObj) {
                [array addObject:[o toDictionaryOrArrayWithDepth:depth - 1]];
            }
        }
        return array;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *selfObj = (NSDictionary *) self;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:[selfObj count]];
        if (depth > 0) {
            [selfObj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [dic setObject:[obj toDictionaryOrArrayWithDepth:depth - 1]
                        forKey:key];
            }];
        }
        return dic;
    } else if ([self isKindOfClass:[NSNull class]] || [self isKindOfClass:[NSNumber class]]
            || [self isKindOfClass:[NSString class]]) {
        return self;
    } else if (self == nil) {
        return [NSNull null];
    } else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        Class clazz = [self class];

        [PropertyAttributeInfo enumerateClassProperties:clazz
                                          withInfoBlock:^(Class oriClass, Class currentClass, PropertyAttributeInfo *info) {
                                              [self getPropertyToDictionary:dic
                                                                  pProperty:info
                                                                  withDepth:depth
                                                                  withClass:clazz];
                                          }];

        return dic;
    }
}

- (void)getPropertyToDictionary:(NSMutableDictionary *)dictionary
                      pProperty:(PropertyAttributeInfo *)attributeInfo
                      withDepth:(NSUInteger)depth
                      withClass:(Class)clazz {

    if (attributeInfo.transient) {
        //不需要对这个字段进行序列化
        return;
    }
    SEL getter = attributeInfo.getter;
    id retForId = nil;
    char retForChar;
    unsigned char retForUnsignedChar;
    bool retForBool;
    double retForDouble;
    int retForInt;
    float retForFloat;
    long retForLong;
    unsigned long retForUnsignedLong;
    long long retForLongLong;
    unsigned long long retForUnsignedLongLong;
    short retForShort;
    unsigned short retForUnsignedShort;
    unsigned retForUnsigned;
    switch (attributeInfo.type) {
        case TBIU_CHAR:
            retForChar = ((char ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithChar:retForChar]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_UNSIGNED_CHAR:
            retForUnsignedChar = ((unsigned char ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithUnsignedChar:retForUnsignedChar]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_C_BOOL:
            retForBool = ((bool ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithBool:retForBool]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_DOUBLE:
            retForDouble = ((double ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithDouble:retForDouble]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_INT:
            retForInt = ((int ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithInt:retForInt]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_FLOAT:
            retForFloat = ((float ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithFloat:retForFloat]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_LONG:
            retForLong = ((long ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithLong:retForLong]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_UNSIGNED_LONG:
            retForUnsignedLong = ((unsigned long ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithUnsignedLong:retForUnsignedLong]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_LONG_LONG:
            retForLongLong = ((long long ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithLongLong:retForLongLong]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_UNSIGNED_LONG_LONG:
            retForUnsignedLongLong = ((unsigned long long ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithUnsignedLongLong:retForUnsignedLongLong]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_SHORT:
            retForShort = ((short ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithShort:retForShort]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_UNSIGNED_SHORT:
            retForUnsignedShort = ((unsigned short ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithUnsignedShort:retForUnsignedShort]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_UNSIGNED:
            retForUnsigned = ((unsigned ( *)(id, SEL)) objc_msgSend)(self, getter);
            [dictionary setObject:[NSNumber numberWithUnsignedInt:retForUnsigned]
                           forKey:attributeInfo.dicPropertyName];
            return;
        case TBIU_ID:
            retForId = objc_msgSend(self, getter);
            if (retForId) {
                if ([retForId isKindOfClass:[NSString class]] || [retForId isKindOfClass:[NSNumber class]]) {
                    [dictionary setObject:retForId
                                   forKey:attributeInfo.dicPropertyName];
                } else {
                    if (depth == 0) {
                        return;
                    }
                    [dictionary setObject:[retForId toDictionaryOrArrayWithDepth:depth - 1]
                                   forKey:attributeInfo
                                           .dicPropertyName];
                }
            }
            return;
        default:
            break;
    }


}

@end