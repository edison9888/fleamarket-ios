//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-19 上午8:40.
//


#import <FMDB/FMResultSet.h>
#import <objc/message.h>
#import "TBIUEasyDBMapping.h"
#import "TBIUConvertDefine.h"

@implementation TBIUSQLAndArgs {
@private
    NSString *_sql;
    NSArray *_args;
}

@synthesize sql = _sql;
@synthesize args = _args;

- (id)initWithSql:(NSString *)sql args:(NSArray *)args {
    self = [super init];
    if (self) {
        self.sql = sql;
        self.args = args;
    }

    return self;
}

+ (id)argsWithSql:(NSString *)sql args:(NSArray *)args {
    return [[self alloc]
                  initWithSql:sql
                         args:args];
}

- (BOOL)isValid {
    return _args.count > 0;
}


@end


@implementation TBIUEasyDBMapping {

}

//获取列信息
+ (NSString *)getDBColumn:(PropertyAttributeInfo *)info AndWithCurrentClass:(Class)currentClass {
    NSString *propertyName = info.oriPropertyName;
    NSDictionary *annotations = ext_getPropertyAnnotation(currentClass, propertyName);
    NSString *dbColumn = [annotations objectForKey:TBIU_DB_COLUMN];
    if (dbColumn) {
        return dbColumn;
    }
    NSString *dicPropertyName = [info.dicPropertyName copy];
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:dicPropertyName.length + 3];
    [dicPropertyName enumerateSubstringsInRange:NSMakeRange(0, [dicPropertyName length])
                                        options:NSStringEnumerationByComposedCharacterSequences
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                         if ([substring isEqualToString:[substring lowercaseString]]) {
                                             [result appendString:[substring lowercaseString]];
                                         } else {
                                             [result appendFormat:@"_%@",
                                                                  [substring lowercaseString]];
                                         }
                                     }];
    return result;
}


//获取列信息
+ (NSString *)getDBTable:(Class)clazz {
    NSDictionary *annotations = ext_getClassAnnotation(clazz);
    NSString *dbTable = [annotations objectForKey:TBIU_DB_TABLE];
    if (dbTable) {
        return dbTable;
    }
    NSString *className = NSStringFromClass(clazz);
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:className.length + 3];
    BOOL _first = YES;
    BOOL *first = &_first;
    [className enumerateSubstringsInRange:NSMakeRange(0, [className length])
                                  options:NSStringEnumerationByComposedCharacterSequences
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                   if (*first || [substring isEqualToString:[substring lowercaseString]]) {
                                       [result appendString:[substring lowercaseString]];
                                   } else {
                                       [result appendFormat:@"_%@",
                                                            [substring lowercaseString]];
                                   }
                                   *first = NO;
                               }];
    return result;
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

static inline id resultSetToObj(FMResultSet *resultSet, NSDictionary *propertiesDic, Class class) {
    id o = [[class alloc] init];
    NSDictionary *dictionary = [resultSet resultDictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id _obj, BOOL *stop) {
        PropertyAttributeInfo *attributeInfo = [propertiesDic objectForKey:key];
        if (attributeInfo && !attributeInfo.readOnly) {
            id propertyValue = _obj;
            SEL propertySetter = attributeInfo.setter;
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
            } else {
                objc_msgSend(o, propertySetter, propertyValue);
            }

        }
    }];
    return o;
}

+ (NSArray *)fromResultSet:(FMResultSet *)resultSet withClass:(Class)class {
    NSMutableDictionary *propertiesDic = [NSMutableDictionary dictionary];
    [PropertyAttributeInfo enumerateClassProperties:class
                                      withInfoBlock:^(Class oriClass, Class currentClass, PropertyAttributeInfo *info) {
                                          [propertiesDic setObject:info
                                                            forKey:[self getDBColumn:info
                                                                 AndWithCurrentClass:currentClass]];
                                      }];

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        id o = resultSetToObj(resultSet, propertiesDic, class);
        [resultArray addObject:o];
    }
    [resultSet close];

    return resultArray;
}

+ (id)fromOneResultSet:(FMResultSet *)resultSet withClass:(Class)clazz {
    NSMutableDictionary *propertiesDic = [NSMutableDictionary dictionary];
    [PropertyAttributeInfo enumerateClassProperties:clazz
                                      withInfoBlock:^(Class oriClass, Class currentClass, PropertyAttributeInfo *info) {
                                          [propertiesDic setObject:info
                                                            forKey:[self getDBColumn:info
                                                                 AndWithCurrentClass:currentClass]];
                                      }];
    id o = nil;
    if ([resultSet next]) {
        o = resultSetToObj(resultSet, propertiesDic, clazz);
    }
    [resultSet close];
    return o;
}

+ (TBIUSQLAndArgs *)queryStringByExample:(id)obj {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE ",
                                                             [self getDBTable:[obj class]]];
    NSMutableArray *args = [NSMutableArray array];
    BOOL _hasCondition = NO;
    BOOL *hasCondition = &_hasCondition;
    [PropertyAttributeInfo enumerateClassProperties:[obj class]
                                      withInfoBlock:^(Class oriClass, Class currentClass, PropertyAttributeInfo *info) {
                                          id o = [PropertyAttributeInfo getValue:obj
                                                                            with:info];
                                          if (o) {
                                              if (*hasCondition) {
                                                  [sql appendString:@" AND "];
                                              }
                                              [sql appendFormat:@" %@ = ? ",
                                                                [self getDBColumn:info
                                                              AndWithCurrentClass:currentClass]];
                                              [args addObject:o];
                                              *hasCondition = YES;
                                          }
                                      }];


    return [TBIUSQLAndArgs argsWithSql:sql
                                  args:args];
}


@end