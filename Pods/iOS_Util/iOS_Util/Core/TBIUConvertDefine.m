//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午12:20.
//


#import <objc/message.h>
#import "TBIUConvertDefine.h"


@implementation PropertyAttributeInfoCache {
@private
    NSCache *_cache;

}
+ (PropertyAttributeInfoCache *)instance {
    static PropertyAttributeInfoCache *_instance = nil;
    static dispatch_once_t _oncePredicate_PropertyAttributeInfoCache;

    dispatch_once(&_oncePredicate_PropertyAttributeInfoCache, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)dealloc {
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}


- (PropertyAttributeInfo *)getFromCacheWithClass:(Class)class AndPropertyName:(NSString *)name {
    @synchronized (self) {
        NSDictionary *proInfos = [_cache objectForKey:NSStringFromClass(class)];
        if (proInfos) {
            PropertyAttributeInfo *info = [proInfos objectForKey:name];
            return info;
        }
        return nil;
    }
}

- (void)putToCacheWithClass:(Class)class AndPropertyName:(NSString *)name WithInfo:(PropertyAttributeInfo *)info {
    @synchronized (self) {
        NSMutableDictionary *proInfos = [_cache objectForKey:NSStringFromClass(class)];
        if (proInfos == nil) {
            proInfos = [[NSMutableDictionary alloc] initWithCapacity:1];
            [_cache setObject:proInfos
                       forKey:NSStringFromClass(class)];
        }
        [proInfos setObject:info
                     forKey:name];
    }
}

- (void)clearCache {
    @synchronized (self) {
        [_cache removeAllObjects];
    }
}


@end


@implementation PropertyAttributeInfo {
@private
    BOOL _transient;
    BOOL _readOnly;
    TBIU_TypeOfProperty _type;
    Class _clazz;
    Class _arrayClass;
    NSString *_dicPropertyName;
    NSString *_oriPropertyName;
    SEL _getter;
    SEL _setter;
}

@synthesize transient = _transient;
@synthesize readOnly = _readOnly;
@synthesize type = _type;
@synthesize clazz = _clazz;
@synthesize arrayClass = _arrayClass;
@synthesize dicPropertyName = _dicPropertyName;
@synthesize oriPropertyName = _oriPropertyName;

@synthesize getter = _getter;
@synthesize setter = _setter;

+ (PropertyAttributeInfo *)analyseProperty:(objc_property_t)pProperty
                                 WithClass:(Class)aClass
                       AndWithCurrentClass:(Class)currentClass {

    NSMutableString *propertyName = [NSMutableString stringWithUTF8String:property_getName(pProperty)];
    PropertyAttributeInfo *info;
    if ((info = [[PropertyAttributeInfoCache instance] getFromCacheWithClass:aClass
                                                             AndPropertyName:propertyName]) != nil) {
        return info;
    }
    ext_propertyAttributes *pAttributes = ext_copyPropertyAttributes(pProperty);
    if (NULL == pAttributes) {
        return nil;
    }
    TBIU_TypeOfProperty typeOfProperty = TBIU_NIL;
    Class class = nil;
    BOOL readOnly = pAttributes->readonly;
    Class arrayClass = nil;
    NSString *dicPropertyName = propertyName;
    NSDictionary *annotations = ext_getPropertyAnnotation(currentClass, propertyName);
    NSString *typeAtt = [NSString stringWithCString:pAttributes->type
                                           encoding:NSUTF8StringEncoding];
    if ([typeAtt hasPrefix:@"c"]) {
        typeOfProperty = TBIU_CHAR;
    } else if ([typeAtt hasPrefix:@"C"]) {
        typeOfProperty = TBIU_UNSIGNED_CHAR;
    } else if ([typeAtt hasPrefix:@"B"]) {
        typeOfProperty = TBIU_C_BOOL;
    } else if ([typeAtt hasPrefix:@"d"]) {
        typeOfProperty = TBIU_DOUBLE;
    } else if ([typeAtt hasPrefix:@"i"]) {
        typeOfProperty = TBIU_INT;
    } else if ([typeAtt hasPrefix:@"f"]) {
        typeOfProperty = TBIU_FLOAT;
    } else if ([typeAtt hasPrefix:@"l"]) {
        typeOfProperty = TBIU_LONG;
    } else if ([typeAtt hasPrefix:@"L"]) {
        typeOfProperty = TBIU_UNSIGNED_LONG;
    } else if ([typeAtt hasPrefix:@"q"]) {
        typeOfProperty = TBIU_LONG_LONG;
    } else if ([typeAtt hasPrefix:@"Q"]) {
        typeOfProperty = TBIU_UNSIGNED_LONG_LONG;
    } else if ([typeAtt hasPrefix:@"s"]) {
        typeOfProperty = TBIU_SHORT;
    } else if ([typeAtt hasPrefix:@"S"]) {
        typeOfProperty = TBIU_UNSIGNED_SHORT;
    } else if ([typeAtt hasPrefix:@"{"]) {
        typeOfProperty = TBIU_STRUCT;
    } else if ([typeAtt hasPrefix:@"I"]) {
        typeOfProperty = TBIU_UNSIGNED;
    } else if ([typeAtt hasPrefix:@"^i"]) {
        typeOfProperty = TBIU_INT_P;
    } else if ([typeAtt hasPrefix:@"^v"]) {
        typeOfProperty = TBIU_VOID_P;
    } else if ([typeAtt hasPrefix:@"^?"]) {
        typeOfProperty = TBIU_FUNC;
    } else if ([typeAtt hasPrefix:@"*"]) {
        typeOfProperty = TBIU_CHAR_P;
    } else if ([typeAtt hasPrefix:@"@"]) {
        if ([typeAtt hasSuffix:[NSString stringWithCString:@encode(void (^)())
                                                  encoding:NSUTF8StringEncoding]]) {
            typeOfProperty = TBIU_BLOCK;
        } else {
            typeOfProperty = TBIU_ID;
            class = pAttributes->objectClass;
            if ([class isSubclassOfClass:[NSArray class]] || [class isSubclassOfClass:[NSSet class]]) {
                NSUInteger location = [propertyName rangeOfString:@"$"].location;
                if (location != NSNotFound) {
                    arrayClass = NSClassFromString([propertyName substringWithRange:NSMakeRange(location + 1,
                            [propertyName length] - location - 1
                    )]
                    );
                    dicPropertyName = [NSString stringWithString:[propertyName substringWithRange:NSMakeRange(0,
                            location
                    )]];
                } else {
                    NSString *type = [annotations objectForKey:TBIU_ANN_TYPE];
                    if (type) {
                        arrayClass = NSClassFromString(type);
                    }
                }
            }
        }
    }

    NSString *mapping = [annotations objectForKey:TBIU_ANN_MAPPING];
    if (mapping) {
        dicPropertyName = mapping;
    }

    info = [[PropertyAttributeInfo alloc] init];
    info.readOnly = readOnly;
    info.clazz = class;
    info.type = typeOfProperty;
    info.arrayClass = arrayClass;
    info.dicPropertyName = dicPropertyName;
    info.oriPropertyName = propertyName;
    info.transient = [propertyName hasPrefix:@"_"] ||
            [[annotations objectForKey:TBIU_ANN_TRANSIENT] isEqual:@"1"];
    info.setter = pAttributes->setter;
    info.getter = pAttributes->getter;
    [[PropertyAttributeInfoCache instance]
                                 putToCacheWithClass:aClass
                                     AndPropertyName:propertyName
                                            WithInfo:info];
    if (pAttributes != NULL) {
        free(pAttributes);
    }
    return info;

}

+ (void)enumerateClassProperties:(Class)aClass
                   withInfoBlock:(void (^)(Class oriClass, Class currentClass, PropertyAttributeInfo *info))
                           infoBlock {
    if (!infoBlock) {
        return;
    }
    Class clazz = aClass;
    while (clazz != nil) {
        if (clazz == [NSObject class]) {
            break;
        }
        unsigned int propertyCount;
        objc_property_t *pProperty = class_copyPropertyList(clazz, &propertyCount);
        if (pProperty && propertyCount > 0) {
            for (unsigned int i = 0; i < propertyCount; i++) {
                PropertyAttributeInfo *info = [PropertyAttributeInfo analyseProperty:pProperty[i]
                                                                           WithClass:aClass
                                                                 AndWithCurrentClass:clazz];
                if (![info.oriPropertyName hasSuffix:@"ext_annotation_marker"]) {
                    infoBlock(aClass, clazz, info);
                }
            }
        }
        if (pProperty) {
            free(pProperty);
        }
        clazz = class_getSuperclass(clazz);
    }
}

+ (id)getValue:(id)obj with:(PropertyAttributeInfo *)attributeInfo {
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
            retForChar = ((char ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithChar:retForChar];
        case TBIU_UNSIGNED_CHAR:
            retForUnsignedChar = ((unsigned char ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithUnsignedChar:retForUnsignedChar];
        case TBIU_C_BOOL:
            retForBool = ((bool ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithBool:retForBool];
        case TBIU_DOUBLE:
            retForDouble = ((double ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithDouble:retForDouble];
        case TBIU_INT:
            retForInt = ((int ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithInt:retForInt];
        case TBIU_FLOAT:
            retForFloat = ((float ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithFloat:retForFloat];
        case TBIU_LONG:
            retForLong = ((long ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithLong:retForLong];
        case TBIU_UNSIGNED_LONG:
            retForUnsignedLong = ((unsigned long ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithUnsignedLong:retForUnsignedLong];
        case TBIU_LONG_LONG:
            retForLongLong = ((long long ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithLongLong:retForLongLong];
        case TBIU_UNSIGNED_LONG_LONG:
            retForUnsignedLongLong = ((unsigned long long ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithUnsignedLongLong:retForUnsignedLongLong];
        case TBIU_SHORT:
            retForShort = ((short ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithShort:retForShort];
        case TBIU_UNSIGNED_SHORT:
            retForUnsignedShort = ((unsigned short ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithUnsignedShort:retForUnsignedShort];
        case TBIU_UNSIGNED:
            retForUnsigned = ((unsigned ( *)(id, SEL)) objc_msgSend)(obj, getter);
            return [NSNumber numberWithUnsignedInt:retForUnsigned];
        case TBIU_ID:
            retForId = objc_msgSend(obj, getter);
            return retForId;
        default:
            break;
    }
    return nil;
}


@end