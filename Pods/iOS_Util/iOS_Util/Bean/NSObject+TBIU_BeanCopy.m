//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-5-22 下午4:59.
//


#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+TBIU_BeanCopy.h"
#import "TBIUConvertDefine.h"


inline NSDictionary *TBIUGetProperty(Class clazz) {
    __autoreleasing NSMutableDictionary *result = nil;
    Class currentClazz = clazz;
    while (currentClazz != nil) {
        unsigned int propertyCount;
        objc_property_t *pProperty = class_copyPropertyList(currentClazz, &propertyCount);
        if (pProperty && propertyCount > 0) {
            if (!result) {
                result = [[NSMutableDictionary alloc] initWithCapacity:propertyCount];
            }
            for (unsigned int i = 0; i < propertyCount; i++) {
                PropertyAttributeInfo *attributeInfo = [PropertyAttributeInfo analyseProperty:pProperty[i]
                                                                                    WithClass:clazz
                                                                          AndWithCurrentClass:currentClazz];
                [result setObject:attributeInfo
                           forKey:attributeInfo.oriPropertyName];
            }
        }
        if (pProperty) {
            free(pProperty);
        }
        currentClazz = class_getSuperclass(currentClazz);
        if (currentClazz == [NSObject class]) {
            break;
        }
    }
    return result;
}


inline void TBIUBeanCopy(NSObject *src, NSObject *dest) {
    if (!(dest && src)) {return;}
    if (dest == src) {return;}
    NSDictionary *srcProperties = TBIUGetProperty([src class]);
    NSDictionary *destProperties = TBIUGetProperty([dest class]);
    NSArray *properties = nil;
    if ([srcProperties count] >= [destProperties count]) {
        properties = [destProperties allKeys];
    } else {
        properties = [srcProperties allKeys];
    }

    if (!properties || [properties count] == 0) {return;}
    for (NSString *key in properties) {
        PropertyAttributeInfo *srcPropertyInfo = [srcProperties objectForKey:key];
        PropertyAttributeInfo *destPropertyInfo = [destProperties objectForKey:key];
        if (srcPropertyInfo && srcPropertyInfo) {
            SEL getter = srcPropertyInfo.getter;
            SEL setter = destPropertyInfo.setter;
            if (getter && setter && [src respondsToSelector:getter] && [dest respondsToSelector:setter]) {
                if (srcPropertyInfo.type == destPropertyInfo.type &&
                        (srcPropertyInfo.clazz == destPropertyInfo.clazz ||
                                [srcPropertyInfo.clazz isSubclassOfClass:destPropertyInfo.clazz])) {
                    __unsafe_unretained id value = objc_msgSend(src, getter);
                    objc_msgSend(dest, setter, value);
                }
            }
        }
    }
}


@implementation NSObject (TBIU_BeanCopy)

- (void)cloneToBean:(NSObject *)dest {
    TBIUBeanCopy(self, dest);
}

- (id)cloneToNewBean:(Class)clazz {
    id dest = [[clazz alloc] init];
    TBIUBeanCopy(self, dest);
    return dest;
}

- (void)fromBean:(NSObject *)src {
    TBIUBeanCopy(src, self);
}

@end