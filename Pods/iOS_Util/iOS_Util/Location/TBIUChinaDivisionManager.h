//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-14 下午2:43.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TBIUEasyDBMapping.h"

#define KRootLocation        (1)


@interface TBIULocationDetail : NSObject
@property(nonatomic, copy) NSString *province, *city, *district;
@annotate(TBIULocationDetail, TBIU_DB_COLUMN: @"location_id")
@property(nonatomic, assign) NSInteger locationID;
@annotate(TBIULocationDetail, TBIU_DB_COLUMN: @"father_id")
@property(nonatomic, assign) NSInteger fatherID;

- (NSString *)description;
@end


@annotateClass(TBIULocationExample, TBIU_DB_TABLE: @"locations")
@interface TBIULocationExample : NSObject
@property(nonatomic, copy) NSString *province, *city, *district;
@property(nonatomic, strong) NSNumber *locationId;
@property(nonatomic, strong) NSNumber *fatherId;

- (NSString *)description;

@end

@interface TBIUChinaDivisionManager : NSObject

+ (TBIUChinaDivisionManager *)instance;

- (void)locationWithID:(NSInteger)locationId withResult:(void (^)(TBIULocationDetail *detail))resultCallback;

- (void)locationWithIDs:(NSArray *)locationIds withResult:(void (^)(NSArray *details))resultCallback;

- (void)locationWithFatherID:(NSInteger)locationId withResult:(void (^)(NSArray *details))resultCallback;

- (void)locationsWithProvince:(NSString *)province
                      theCity:(NSString *)city
                  theDistrict:(NSString *)district
                   withResult:(void (^)(NSArray *details))resultCallback;

- (void)locationsWithEnProvince:(NSString *)province
                        theCity:(NSString *)city
                    theDistrict:(NSString *)district
                     withResult:(void (^)(NSArray *details))resultCallback;

- (void)locationsWithExample:(TBIULocationExample *)example
                   withResult:(void (^)(NSArray *details))resultCallback;

- (void)locationsWithPlacemark:(MKPlacemark *)placemark withResult:(void (^)(NSArray *details))resultCallback;
@end