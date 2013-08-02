//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-19 上午8:40.
//


#import <Foundation/Foundation.h>
#import "TBIUConvertDefine.h"

#define TBIU_DB_COLUMN  @"DB_COLUMN"

#define TBIU_DB_TABLE   @"DB_TABLE"

@class FMResultSet;

@interface TBIUSQLAndArgs : NSObject
@property(nonatomic, copy) NSString *sql;
@property(nonatomic, strong) NSArray *args;

- (id)initWithSql:(NSString *)sql args:(NSArray *)args;

+ (id)argsWithSql:(NSString *)sql args:(NSArray *)args;

-(BOOL) isValid;

@end

@interface TBIUEasyDBMapping : NSObject

+ (NSArray *)fromResultSet:(FMResultSet *)resultSet withClass:(Class)clazz;

+ (id)fromOneResultSet:(FMResultSet *)resultSet withClass:(Class)clazz;

+ (TBIUSQLAndArgs *)queryStringByExample:(id)obj;

@end