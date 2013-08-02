//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午7:39.
//


#import "NSDictionary+TBIU_ToObject.h"
#import "TBIUConvertDefine.h"
#import <objc/message.h>


@interface NSDictionary (Private)

- (void)setPropertyToObject:(id)o pProperty:(objc_property_t)pProperty withDepth:(NSUInteger)depth;

@end

@implementation NSDictionary (TBIU_ToObject)

- (id)toObjectWithClass:(Class)class withDepth:(NSUInteger)depth {
    id o = [[class alloc] init];
    [self toObjectWithExistObject:o
                        withDepth:depth];
    return o;
}

- (id)toObjectWithExistObject:(id)obj {
    return [self toObjectWithExistObject:obj
                               withDepth:8];
}

- (id)toObjectWithExistObject:(id)obj withDepth:(NSUInteger)depth {
    id o = obj;
    Class class = [obj class];
    if (o) {
        [PropertyAttributeInfo enumerateClassProperties:class
                                          withInfoBlock:^(Class oriClass, Class currentClass, PropertyAttributeInfo *info) {
                                              [self setPropertyToObject:o
                                                              pProperty:info
                                                              withDepth:depth
                                                               AndClass:oriClass
                                                        AndCurrentClass:currentClass];
                                          }];
    }
    return o;
}


- (id)toObjectWithClass:(Class)class {
    return [self toObjectWithClass:class
                         withDepth:8];
}

static BOOL _isKindOf(Class class, Class kind) {
    Class clazz = class;
    while (clazz) {
        if (clazz == kind) {
            return YES;
        }
        clazz = class_getSuperclass(clazz);
    }
    return NO;
}

- (void)setPropertyToObject:(id)o
                  pProperty:(PropertyAttributeInfo *)attributeInfo
                  withDepth:(NSUInteger)depth
                   AndClass:(Class)
                           class
            AndCurrentClass:(Class)currentClass {
    if (attributeInfo.readOnly || attributeInfo.transient) {
        return;
    }
    id propertyValue = [self objectForKey:[attributeInfo dicPropertyName]];
    if (propertyValue) {
        SEL propertySetter = attributeInfo.setter;
        if ([o respondsToSelector:propertySetter]) {
            if ([propertyValue isKindOfClass:[NSNumber class]] || [propertyValue isKindOfClass:[NSString class]]) {
                NSNumber *numberValue;
                if ([propertyValue isKindOfClass:[NSString class]]) {
                    numberValue = [[[NSNumberFormatter alloc] init] numberFromString:propertyValue];
                } else {
                    numberValue = propertyValue;
                }
                if (!numberValue) {
                    numberValue = [NSNumber numberWithInteger:0];
                }
                switch (attributeInfo.type) {
                    case TBIU_CHAR:
                        objc_msgSend(o, propertySetter, [numberValue charValue]);
                        return;
                    case TBIU_UNSIGNED_CHAR:
                        objc_msgSend(o, propertySetter, [numberValue unsignedCharValue]);
                        return;
                    case TBIU_C_BOOL:
                        objc_msgSend(o, propertySetter, [numberValue boolValue]);
                        return;
                    case TBIU_DOUBLE:
                        objc_msgSend(o, propertySetter, [numberValue doubleValue]);
                        return;
                    case TBIU_INT:
                        objc_msgSend(o, propertySetter, [numberValue integerValue]);
                        return;
                    case TBIU_FLOAT:
                        objc_msgSend(o, propertySetter, [numberValue floatValue]);
                        return;
                    case TBIU_LONG:
                        objc_msgSend(o, propertySetter, [numberValue longValue]);
                        return;
                    case TBIU_LONG_LONG:
                        objc_msgSend(o, propertySetter, [numberValue longLongValue]);
                        return;
                    case TBIU_UNSIGNED_LONG:
                        objc_msgSend(o, propertySetter, [numberValue unsignedLongValue]);
                        return;
                    case TBIU_UNSIGNED_LONG_LONG:
                        objc_msgSend(o, propertySetter, [numberValue unsignedLongLongValue]);
                        return;
                    case TBIU_SHORT:
                        objc_msgSend(o, propertySetter, [numberValue shortValue]);
                        return;
                    case TBIU_UNSIGNED_SHORT:
                        objc_msgSend(o, propertySetter, [numberValue unsignedShortValue]);
                        return;
                    case TBIU_UNSIGNED:
                        objc_msgSend(o, propertySetter, [numberValue unsignedIntValue]);
                        return;
                    case TBIU_ID:
                        if (attributeInfo.clazz && _isKindOf(attributeInfo.clazz, [NSNumber class])) {
                            objc_msgSend(o, propertySetter, numberValue);
                            return;
                        } else if (attributeInfo.clazz && _isKindOf(attributeInfo.clazz, [NSString class])) {
                            objc_msgSend(o, propertySetter, [attributeInfo.clazz stringWithFormat:@"%@",
                                                                                                  propertyValue]
                            );
                            return;
                        }
                    default:
                        break;
                }
            } else if ([propertyValue isKindOfClass:[NSNull class]]) {
                objc_msgSend(o, propertySetter, nil);
                return;
            } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                if (attributeInfo.type == TBIU_ID && attributeInfo.clazz != nil) {
                    if ([attributeInfo.clazz isSubclassOfClass:[NSArray class]]) {
                        if (depth == 0) {
                            return; //达到深度了 不再解析
                        }
                        NSMutableArray *arrayValue = [[NSMutableArray alloc] initWithCapacity:[propertyValue count]];
                        for (id v in propertyValue) {
                            if ([v isKindOfClass:[NSDictionary class]] && attributeInfo.arrayClass != nil) {
                                [arrayValue addObject:[v toObjectWithClass:attributeInfo.arrayClass
                                                                 withDepth:depth - 1]];
                            } else {
                                [arrayValue addObject:v];
                            }
                        }
                        objc_msgSend(o, propertySetter, arrayValue);
                        return;
                    } else if ([attributeInfo.clazz isSubclassOfClass:[NSSet class]]) {
                        if (depth == 0) {
                            return; //达到深度了 不再解析
                        }
                        NSMutableSet *setValue = [[NSMutableSet alloc]
                                                                initWithCapacity:[propertyValue count]];
                        for (id v in propertyValue) {
                            if ([v isKindOfClass:[NSDictionary class]] && attributeInfo.arrayClass != nil) {
                                [setValue addObject:[v toObjectWithClass:attributeInfo.arrayClass
                                                               withDepth:depth - 1]];
                            } else {
                                [setValue addObject:v];
                            }
                        }
                        objc_msgSend(o, propertySetter, setValue);
                        return;
                    }
                }
            } else if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                if (attributeInfo.type == TBIU_ID && attributeInfo.clazz != nil) {
                    if (![attributeInfo.clazz isSubclassOfClass:[NSDictionary class]]) {
                        if (depth == 0) {
                            return; //达到深度了 不再解析
                        }
                        objc_msgSend(o, propertySetter, [propertyValue toObjectWithClass:attributeInfo.clazz
                                                                               withDepth:depth - 1]
                        );
                        return;
                    }
                }
            }
            //LAST ONE
            if (attributeInfo.clazz && _isKindOf(attributeInfo.clazz, [NSString class])) {
                objc_msgSend(o, propertySetter, [attributeInfo.clazz stringWithFormat:@"%@",
                                                                                      propertyValue]
                );
            } else {
                objc_msgSend(o, propertySetter, propertyValue);
            }
            return;
        }
    }
}

@end