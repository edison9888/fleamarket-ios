//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-24 下午2:14.
//


#import "FMMessageDAO.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMMessageInfo.h"
#import "FMMessageSearchCondition.h"
#import "FMDatabaseAdditions.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMDatabaseQueue+TBIU_Additions.h"


#define DB_FILE_NAME @"message.db"

#define DB_PATH_NAME @"message"


@implementation FMMessageDAO {
@private
    FMDatabaseQueue *_databaseQueue;
    NSCache *_cache;
}

+ (FMMessageDAO *)instance {
    static FMMessageDAO *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}


+ (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [NSString stringWithFormat:@"%@/%@",
                                      [paths objectAtIndex:0],
                                      DB_PATH_NAME];
}

- (void)initMessageDB {
    NSString *dbPath = [FMMessageDAO dbPath];
    FMLOG(@"%@", dbPath);
    if ([[NSFileManager defaultManager]
                        createDirectoryAtPath:dbPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL]) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[NSString stringWithFormat:@"%@/%@",
                                                                                           dbPath,
                                                                                           DB_FILE_NAME]];
        [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {

            const char *message_info_create_sql = "CREATE TABLE IF NOT EXISTS \"message_info\" (\n"
                    "\t \"id\" integer NOT NULL PRIMARY KEY AUTOINCREMENT,\n"
                    "\t \"user_id\" text NOT NULL,\n"
                    "\t \"type\" integer NOT NULL,\n"
                    "\t \"unread\" integer NOT NULL,\n"
                    "\t \"item_id\" text,\n"
                    "\t \"reporter_id\" text,\n"
                    "\t \"reporter_nick\" text,\n"
                    "\t \"reporter_name\" text,\n"
                    "\t \"comment_type\" integer NOT NULL,\n"
                    "\t \"comment_id\" text,\n"
                    "\t \"content\" text,\n"
                    "\t \"last_time\" text\n"
                    ");";
            sqlite3_exec([db sqliteHandle], message_info_create_sql, NULL, NULL, NULL);

            const char *message_info_index_sql = "CREATE INDEX IF NOT EXISTS \"idx_all\" ON message_info "
                    "(user_id ASC, type ASC, item_id ASC, reporter_id ASC, unread ASC);";
            sqlite3_exec([db sqliteHandle], message_info_index_sql, NULL, NULL, NULL);

            const char *message_info_comment_id_index_sql = "CREATE UNIQUE INDEX IF NOT EXISTS \"idx_comment_id\" ON "
                    "message_info (comment_id,reporter_id);";
            sqlite3_exec([db sqliteHandle], message_info_comment_id_index_sql, NULL, NULL, NULL);

            return nil;
        }
                             withResult:NULL];
    } else {
        FMLOG(@"Create file error [%@]!", dbPath);
    }
}


- (void)getAllMessageSummary:(void (^)(NSArray *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT id,user_id,type,sum(unread),item_id,reporter_id,"
                                                          "reporter_nick,reporter_name,content,"
                                                          "last_time FROM message_info WHERE user_id=? GROUP BY type,"
                                                          "item_id, reporter_id",
                                                  userId];
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:10];
        FMMessageSummary *hasSold = nil;
        FMMessageSummary *hasBuy = nil;
        BOOL hasSystem = NO;
        BOOL hasActivity = NO;
        while ([resultSet next]) {
            FMMessageSummary *summary = [FMMessageSummary objectFromFMResultSet:resultSet];
            if (summary.type == BUY) {
                if (!hasBuy) {
                    [ret addObject:summary];
                    hasBuy = summary;
                } else {
                    [hasBuy overWrite:summary];
                }
            } else if (summary.type == SOLD) {
                if (!hasSold) {
                    [ret addObject:summary];
                    hasSold = summary;
                } else {
                    [hasSold overWrite:summary];
                }
            } else if (summary.type == SYSTEM) {
                hasSystem = YES;
                [ret addObject:summary];
            } else if (summary.type == ACTIVITY) {
                hasActivity = YES;
                [ret addObject:summary];
            } else {
                [ret addObject:summary];
            }
        }
        [resultSet close];
        [resultSet setParentDB:nil];
        [ret sortUsingComparator:^NSComparisonResult(FMMessageSummary *obj1, FMMessageSummary *obj2) {
            return [obj2.lastTime compare:obj1.lastTime];
        }];
        if (!hasBuy) {
            [ret addObject:[FMMessageSummary objectWithType:BUY
                                                  AndUserId:userId]];
        }
        if (!hasSold) {
            [ret addObject:[FMMessageSummary objectWithType:SOLD
                                                  AndUserId:userId]];
        }
//        if (!hasSystem) {
//            [ret addObject:[FMMessageSummary objectWithType:SYSTEM AndUserId:userId]];
//        }
//        if (!hasActivity) {
//            [ret addObject:[FMMessageSummary objectWithType:ACTIVITY AndUserId:userId]];
//        }
        return ret;
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}


- (void)getMessageSummaryByType:(FMessageType)type result:(void (^)(NSArray *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT id,user_id,type,sum(unread),item_id,reporter_id,"
                                                          "reporter_nick,reporter_name,content,"
                                                          "last_time FROM message_info WHERE user_id=? AND type=? "
                                                          "GROUP BY item_id",
                                                  userId,
                                                  [NSNumber numberWithInt:type]];
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:10];
        while ([resultSet next]) {
            FMMessageSummary *summary = [FMMessageSummary objectFromFMResultSet:resultSet];
            [ret addObject:summary];
        }
        [ret sortUsingComparator:^NSComparisonResult(FMMessageSummary *obj1, FMMessageSummary *obj2) {
            return [obj2.lastTime compare:obj1.lastTime];
        }];
        [resultSet close];
        [resultSet setParentDB:nil];
        return ret;
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)getMessageInfoByCondition:(FMMessageSearchCondition *)condition
                           result:(void (^)(NSArray *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    condition.userId = userId;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT id,user_id,type,unread,item_id,reporter_id,"
                                                           "reporter_nick,reporter_name,comment_type,content,"
                                                           "comment_id,"
                                                           "last_time FROM message_info WHERE %@",
                                                   [condition toSQL:YES
                                                           isSelect:YES]];
        FMResultSet *resultSet = [db executeQuery:sql
                             withArgumentsInArray:[condition toArgs:YES]];
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:10];
        while ([resultSet next]) {
            FMMessageInfo *info = [FMMessageInfo objectFromFMResultSet:resultSet];
            [ret addObject:info];
        }
        [resultSet close];
        [resultSet setParentDB:nil];
        return ret;
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}


- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        result:(void (^)(NSArray *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.pageNo = pageNo;
    condition.pageSize = pageSize;
    [self getMessageInfoByCondition:condition
                             result:resultBlock];
}

- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                        result:(void (^)(NSArray *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.pageNo = pageNo;
    condition.pageSize = pageSize;
    [self getMessageInfoByCondition:condition
                             result:resultBlock];
}

- (void)getMessageInfoByPageNo:(NSUInteger)pageNo
                   AndPageSize:(NSUInteger)pageSize
                          type:(FMessageType)type
                        itemId:(NSString *)itemId
                    reporterId:(NSString *)reporterId
                        result:(void (^)(NSArray *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.reporterId = reporterId;
    condition.pageNo = pageNo;
    condition.pageSize = pageSize;
    [self getMessageInfoByCondition:condition
                             result:resultBlock];
}

- (void)getReceiveCommentWithResult:(void (^)(NSArray *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) from  message_info WHERE user_id=%@ AND type=%d AND comment_type=%d",
                                                   userId, COMMENT, RECEIVE];
        FMResultSet *resultSet = [db executeQuery:sql
                             withArgumentsInArray:nil];

        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:10];
        while ([resultSet next]) {
            FMMessageInfo *info = [FMMessageInfo objectFromFMResultSet:resultSet];
            [ret addObject:info];
        }
        [resultSet close];
        [resultSet setParentDB:nil];
        return ret;
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)countUnreadByType:(FMessageType)type itemId:(NSString *)itemId result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    [self countUnreadByCondition:condition
                          result:resultBlock];

}

- (void)countUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.reporterId = reporterId;
    [self countUnreadByCondition:condition
                          result:resultBlock];

}

- (void)countUnreadByCondition:(FMMessageSearchCondition *)condition
                        result:(void (^)(NSNumber *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    condition.userId = userId;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) from  message_info WHERE %@",
                                                   [condition toSQL:NO
                                                           isSelect:NO]];
        FMResultSet *resultSet = [db executeQuery:sql
                             withArgumentsInArray:[condition toArgs:NO]];

        if (![resultSet next]) {
            return [NSNumber numberWithInt:0];
        }
        int ret = [resultSet intForColumnIndex:0];
        [resultSet close];
        [resultSet setParentDB:nil];
        return [NSNumber numberWithInt:ret];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}


- (void)clearUnreadByCondition:(FMMessageSearchCondition *)condition
                        result:(void (^)(NSNumber *))resultBlock {
    [_cache removeAllObjects];
    NSString *userId = [FMApplication instance].loginUser.id;
    condition.userId = userId;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE message_info set unread = 0 WHERE %@",
                                                   [condition toSQL:NO
                                                           isSelect:NO]];
        return [NSNumber numberWithBool:[db executeUpdate:sql
                                     withArgumentsInArray:[condition toArgs:NO]]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)clearUnreadByType:(FMessageType)type result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    [self clearUnreadByCondition:condition
                          result:resultBlock];
}

- (void)clearUnreadByType:(FMessageType)type itemId:(NSString *)itemId result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    [self clearUnreadByCondition:condition
                          result:resultBlock];

}

- (void)clearUnreadByType:(FMessageType)type
                   itemId:(NSString *)itemId
               reporterId:(NSString *)reporterId
                   result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.reporterId = reporterId;
    [self clearUnreadByCondition:condition
                          result:resultBlock];

}

- (void)clearUnreadWithResult:(void (^)(NSNumber *result))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:0];
    [self clearUnreadByCondition:condition
                          result:resultBlock];
}

- (void)clearUnreadWithId:(NSInteger)_id
                   result:(void (^)(NSNumber *result))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE message_info set unread = 0 WHERE user_id=%@ AND id=%d",
                                                   userId, _id];
        return [NSNumber numberWithBool:[db executeUpdate:sql
                                     withArgumentsInArray:nil]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)deleteMessageByCondition:(FMMessageSearchCondition *)condition
                          result:(void (^)(NSNumber *))resultBlock {
    [_cache removeAllObjects];
    NSString *userId = [FMApplication instance].loginUser.id;
    condition.userId = userId;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM message_info WHERE %@",
                                                   [condition toSQL:NO
                                                           isSelect:NO]];
        return [NSNumber numberWithBool:[db executeUpdate:sql
                                     withArgumentsInArray:[condition toArgs:NO]]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)deleteMessageByType:(FMessageType)type result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    [self deleteMessageByCondition:condition
                            result:resultBlock];
}

- (void)deleteMessageByType:(FMessageType)type itemId:(NSString *)itemId result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    [self deleteMessageByCondition:condition
                            result:resultBlock];
}

- (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                 reporterId:(NSString *)reporterId
                     result:(void (^)(NSNumber *))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.reporterId = reporterId;
    [self deleteMessageByCondition:condition
                            result:resultBlock];
}

- (void)deleteMessageByType:(FMessageType)type
                     itemId:(NSString *)itemId
                  commentId:(NSString *)commentId
                     result:(void (^)(NSNumber *result))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:type];
    condition.itemId = itemId;
    condition.commentId = commentId;
    [self deleteMessageByCondition:condition
                            result:resultBlock];
}

- (void)deleteSystemAllMessage:(void (^)(NSNumber *result))resultBlock {
    FMMessageSearchCondition *condition = [[FMMessageSearchCondition alloc] initWithType:SYSTEMALL];
    [self deleteMessageByCondition:condition
                            result:resultBlock];
}

- (void)insertMessageInfo:(FMMessageInfo *)messageInfo result:(void (^)(NSNumber *))resultBlock {
    [self insertMessageInfoNoMax:messageInfo
                          result:^(NSNumber *number) {
                              if (resultBlock) {
                                  resultBlock(number);
                              }
                          }];
}

- (void)insertMessageInfoNoMax:(FMMessageInfo *)messageInfo result:(void (^)(NSNumber *))resultBlock {
    [_cache removeAllObjects];
    NSString *userId = [FMApplication instance].loginUser.id;
    messageInfo.userId = userId;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        NSString *sql = @"insert into message_info ( user_id, type, unread, item_id, reporter_id, reporter_nick, "
                "reporter_name, comment_type ,comment_id,content, last_time ) "
                "values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return [NSNumber numberWithBool:[db executeUpdate:sql
                                     withArgumentsInArray:[messageInfo toArgs]]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)countUnread:(void (^)(NSNumber *))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    NSNumber *resultNum = [_cache objectForKey:[NSString stringWithFormat:@"countUnread_%@",
                                                                          userId]];
    if (resultNum && resultBlock) {
        resultBlock(resultNum);
    }
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        int count = [db intForQuery:@"SELECT count(*) FROM message_info where user_id =? and unread=1",
                                    userId];
        return [NSNumber numberWithInt:count];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 [_cache setObject:result
                                            forKey:[NSString stringWithFormat:@"countUnread_%@",
                                                                              userId]];
                                 resultBlock(result);
                             }
                         }];
}

- (void)countSystemAll:(void (^)(NSNumber *result))resultBlock {
    NSString *userId = [FMApplication instance].loginUser.id;
    NSNumber *resultNum = [_cache objectForKey:[NSString stringWithFormat:@"countSystemAll_%@",
                                                                          userId]];
    if (resultNum && resultBlock) {
        resultBlock(resultNum);
    }
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        int count = [db intForQuery:@"SELECT count(*) FROM message_info where user_id =? and "
                                            "(type=? OR type=? OR type=? OR type=? )",
                                    userId, [NSNumber numberWithInt:BUY], [NSNumber numberWithInt:SOLD],
                                    [NSNumber numberWithInt:SYSTEM], [NSNumber numberWithInt:ACTIVITY]];
        return [NSNumber numberWithInt:count];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 [_cache setObject:result
                                            forKey:[NSString stringWithFormat:@"countSystemAll_%@",
                                                                              userId]];
                                 resultBlock(result);
                             }
                         }];
}

- (void)deleteAllByUser:(void (^)(NSNumber *))resultBlock {
    [_cache removeAllObjects];
    NSString *userId = [FMApplication instance].loginUser.id;
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        return [NSNumber numberWithBool:[db executeUpdate:@"DELETE FROM message_info WHERE user_id=?",
                                                          userId]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}

- (void)deleteAll:(void (^)(NSNumber *))resultBlock {
    [_cache removeAllObjects];
    [_databaseQueue inDatabaseAsync:^id(FMDatabase *db) {
        return [NSNumber numberWithBool:[db executeUpdate:@"DELETE FROM message_info"]];
    }
                         withResult:^(id result) {
                             if (resultBlock) {
                                 resultBlock(result);
                             }
                         }];
}


- (void)dealloc {
    [_databaseQueue close];
    _databaseQueue = nil;

}


@end