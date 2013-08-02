//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-14 下午2:43.
//


#import <FMDB/FMDatabase.h>
#import <MapKit/MapKit.h>
#import "TBIUChinaDivisionManager.h"
#import "FMDatabaseQueue+TBIU_Additions.h"

@implementation TBIULocationDetail

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ",
                                                                     NSStringFromClass([self class])];
    [description appendFormat:@"self.province=%@",
                              self.province];
    [description appendFormat:@", self.city=%@",
                              self.city];
    [description appendFormat:@", self.district=%@",
                              self.district];
    [description appendFormat:@", self.locationID=%i",
                              self.locationID];
    [description appendFormat:@", self.fatherID=%i",
                              self.fatherID];
    [description appendString:@">"];
    return description;
}

@end

@implementation TBIULocationExample {
@private
    NSString *_province;
    NSString *_city;
    NSString *_district;
    NSNumber *_locationId;
    NSNumber *_fatherId;
}

@synthesize province = _province;
@synthesize city = _city;
@synthesize district = _district;
@synthesize locationId = _locationId;
@synthesize fatherId = _fatherId;

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ",
                                                                     NSStringFromClass([self class])];
    [description appendFormat:@"self.province=%@",
                              self.province];
    [description appendFormat:@", self.city=%@",
                              self.city];
    [description appendFormat:@", self.district=%@",
                              self.district];
    [description appendFormat:@", self.locationId=%@",
                              self.locationId];
    [description appendFormat:@", self.fatherId=%@",
                              self.fatherId];
    [description appendString:@">"];
    return description;
}

@end


@implementation TBIUChinaDivisionManager {
@private
    FMDatabaseQueue *_database;
}
+ (TBIUChinaDivisionManager *)instance {
    static TBIUChinaDivisionManager *_instance = nil;
    static dispatch_once_t _oncePredicate_TBIUChinaDivisionManager;

    dispatch_once(&_oncePredicate_TBIUChinaDivisionManager, ^{
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

    }

    return self;
}

- (void)dealloc {
    [_database close];            // close the database connection, clear statement caches
}


- (void)initDatabase {
    // init FMDatabase and get the connection with it
    if (_database == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chinaDivision"
                                                         ofType:@"sqlite"];
        if (!path) {
            NSArray *bundles = [NSBundle allBundles];
            for (NSBundle *bundle in bundles) {
                path = [bundle pathForResource:@"chinaDivision"
                                        ofType:@"sqlite"];
                if (path) {
                    break;
                }
            }
        }
        if (path) {
            _database = [FMDatabaseQueue databaseQueueWithPath:path];
        }
    }
}


- (void)locationWithID:(NSInteger)locationId withResult:(void (^)(TBIULocationDetail *detail))resultCallback {
    [self initDatabase];
    [_database inDatabaseAsync:^id(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from locations where location_id = ?",
                                                  [NSNumber numberWithInt:locationId]];

        TBIULocationDetail *location = [TBIUEasyDBMapping fromOneResultSet:resultSet
                                                                 withClass:[TBIULocationDetail class]];
        return location;
    }
                    withResult:^(TBIULocationDetail *location) {

                        if (resultCallback)
                            resultCallback(location);
                    }];
}

- (void)locationWithIDs:(NSArray *)locationIds withResult:(void (^)(NSArray *details))resultCallback {
    if (locationIds.count <= 0) {
        if (resultCallback)
            resultCallback([NSArray array]);
        return;
    }
    [self initDatabase];
    [_database inDatabaseAsync:^id(FMDatabase *db) {
        NSMutableString *sqlMid = [NSMutableString stringWithString:@"("];
        for (NSUInteger i = 0; i < locationIds.count; i++) {
            [sqlMid appendString:@"?"];
            if (i < locationIds.count - 1) {
                [sqlMid appendString:@","];
            } else {
                [sqlMid appendString:@")"];
            }
        }

        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM locations WHERE location_id IN %@",
                                                   sqlMid];

        FMResultSet *resultSet = [db executeQuery:sql
                             withArgumentsInArray:locationIds];

        NSArray *resultArray = [TBIUEasyDBMapping fromResultSet:resultSet
                                                      withClass:[TBIULocationDetail class]];
        return resultArray;
    }
                    withResult:^(NSArray *details) {
                        if (resultCallback)
                            resultCallback(details);
                    }];
}


- (void)locationWithFatherID:(NSInteger)locationId withResult:(void (^)(NSArray *details))resultCallback {
    TBIULocationExample *example = [[TBIULocationExample alloc] init];
    example.fatherId = [NSNumber numberWithInteger:locationId];
    [self locationsWithExample:example
                    withResult:resultCallback];
}


- (void)locationsWithProvince:(NSString *)province
                      theCity:(NSString *)city
                  theDistrict:(NSString *)district
                   withResult:(void (^)(NSArray *details))resultCallback {
    TBIULocationExample *example = [[TBIULocationExample alloc] init];
    example.province = province;
    example.city = city;
    example.district = district;
    [self locationsWithExample:example
                    withResult:resultCallback];

}

- (void)locationsWithEnProvince:(NSString *)province
                        theCity:(NSString *)city
                    theDistrict:(NSString *)district
                     withResult:(void (^)(NSArray *details))resultCallback {

    if (province.length <= 0 && city.length <= 0 && district.length <= 0) {
        if (resultCallback)
            resultCallback([NSArray array]);
        return;
    }

    [self initDatabase];

    [_database inDatabaseAsync:^id(FMDatabase *db) {
        FMResultSet *results = nil;
        NSMutableString *sql = [NSMutableString stringWithString:@"SELECT * FROM locations_en WHERE "];
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:3];
        BOOL _hasCondition = NO;
        if (province.length > 0) {
            if (_hasCondition) {
                [sql appendString:@" AND "];
            }
            [sql appendString:@" province LIKE ( ? || '%' ) "];
            [args addObject:province];
            _hasCondition = YES;
        }

        if (city.length > 0) {
            if (_hasCondition) {
                [sql appendString:@" AND "];
            }
            [sql appendString:@" city LIKE ( ? || '%' ) "];
            [args addObject:city];
            _hasCondition = YES;
        }

        if (district.length > 0) {
            if (_hasCondition) {
                [sql appendString:@" AND "];
            }
            [sql appendString:@" district LIKE ( ? || '%' ) "];
            [args addObject:district];
        }

        results = [db executeQuery:sql
              withArgumentsInArray:args];

        NSArray *resultArray = [TBIUEasyDBMapping fromResultSet:results
                                                      withClass:[TBIULocationDetail class]];
        return resultArray;
    }
                    withResult:^(NSArray *results) {
                        if (resultCallback)
                            resultCallback(results);
                    }];

}

- (void)locationsWithExample:(TBIULocationExample *)example withResult:(void (^)(NSArray *details))resultCallback {
    TBIUSQLAndArgs *args = [TBIUEasyDBMapping queryStringByExample:example];
    if (!args.isValid) {
        if (resultCallback)
            resultCallback([NSArray array]);
        return;
    }

    [self initDatabase];
    [_database inDatabaseAsync:^id(FMDatabase *db) {
        FMResultSet *results = nil;
        results = [db executeQuery:args.sql
              withArgumentsInArray:args.args];

        NSArray *resultArray = [TBIUEasyDBMapping fromResultSet:results
                                                      withClass:[TBIULocationDetail class]];
        return resultArray;
    }
                    withResult:^(NSArray *results) {
                        if (resultCallback)
                            resultCallback(results);
                    }];
}

- (void)locationsWithPlacemark:(MKPlacemark *)placemark
                    withResult:(void (^)(NSArray *details))resultCallback {
    if ([@"CN" isEqualToString:[placemark.ISOcountryCode uppercaseString]]) {
        if ([[placemark.country lowercaseString] isEqualToString:@"china"]) {
            NSString *province = placemark.administrativeArea;
            NSString *city = placemark.locality;
            NSString *district = placemark.subLocality;
            [self locationsWithEnProvince:province
                                  theCity:city
                              theDistrict:district
                               withResult:^(NSArray *details) {
                                   if (details.count == 0) {
                                       if (resultCallback) {
                                           resultCallback(details);
                                       }
                                       return;
                                   }
                                   NSMutableArray *ids = [NSMutableArray arrayWithCapacity:details.count];
                                   for (TBIULocationDetail *detail in details) {
                                       [ids addObject:[NSNumber numberWithInteger:detail.locationID]];
                                   }
                                   [self locationWithIDs:ids
                                              withResult:resultCallback];

                               }];
        } else {
            NSString *province = placemark.administrativeArea;
            province = [province stringByReplacingOccurrencesOfString:@"省"
                                                           withString:@""];
            //直辖市的处理
            province = [province stringByReplacingOccurrencesOfString:@"市"
                                                           withString:@""];
            NSString *city = placemark.locality;
            city = [city stringByReplacingOccurrencesOfString:@"市"
                                                   withString:@""];

            NSString *district = placemark.subLocality;

            [self locationsWithProvince:province
                                theCity:city
                            theDistrict:district
                             withResult:resultCallback];
        }

    } else {
        if (resultCallback) {
            resultCallback([NSArray array]);
        }
    }

}


@end