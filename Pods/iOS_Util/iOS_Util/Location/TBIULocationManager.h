//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-13 下午6:05.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TBIUCommon.h"

@class TBIULocationManager;


extern NSString *const TBIULocationManagerUserLocationDidChangeNotification;
extern NSString *const TBIULocationManagerNotificationLocationUserInfoKey;
extern NSString *const TBIULocationManagerPlacemarkNotification;
extern NSString *const TBIULocationManagerNotificationPlacemarkUserInfoKey;
extern NSString *const TBIULocationManagerLocationDetailNotification;
extern NSString *const TBIULocationManagerNotificationLocationDetailUserInfoKey;


typedef void(^TBIULocationManagerLocationUpdateBlock)(TBIULocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation);

typedef void (^TBIULocationManagerLocationUpdateFailBlock)(TBIULocationManager *manager, NSError *error);

typedef void(^TBIULocationManagerGeoCodeUpdateBlock)(TBIULocationManager *manager, MKPlacemark *placemark);

typedef void (^TBIULocationManagerGeoCodeUpdateFailBlock)(TBIULocationManager *manager, NSError *error);

@protocol TBIULocationManagerDelegate;
@protocol TBIULocationManagerGeoCoderDelegate;
@protocol TBIULocationManagerPlacemarkParseDelegate;


@interface TBIULocationManager : NSObject

@property(nonatomic, readonly) CLLocation *lastLocation;

/**
 * 开启权限时的提示
 */
@property(nonatomic, copy) NSString *purpose;
@property(nonatomic, assign) BOOL chinaLocationTransform;
#pragma mark - 自定义精度

@property(nonatomic, assign) CLLocationDistance userDistanceFilter;
@property(nonatomic, assign) CLLocationAccuracy userDesiredAccuracy;
@property(nonatomic, assign) BOOL autoGrecoder;
@property(nonatomic, assign) BOOL autoParsePlacemark;
@property(nonatomic, TBIUPropertyWeak) id <TBIULocationManagerDelegate> delegate;
@property(nonatomic, TBIUPropertyWeak) id <TBIULocationManagerGeoCoderDelegate> geoCoderDelegate;
@property(nonatomic, TBIUPropertyWeak) id <TBIULocationManagerPlacemarkParseDelegate> placemarkParseDelegate;

+ (TBIULocationManager *)instance;

#pragma mark - 公用方法

+ (BOOL)locationServicesEnabled;

+ (BOOL)significantLocationChangeMonitoringAvailable;


//开始监听
- (void)startUpdatingLocation;

// 停止监听
- (void)stopUpdatingLocation;

//更新一次
- (void)updateUserLocation;

//带Block回调的更新一次
- (void)updateUserLocationWithBlock:(TBIULocationManagerLocationUpdateBlock)block
                         errorBlock:(TBIULocationManagerLocationUpdateFailBlock)errorBlock;

//根据GPS获取地址
- (void)geocodeUserLocation:(CLLocationCoordinate2D)location;

//根据GPS获取地址
- (void)geocodeUserLocation:(CLLocationCoordinate2D)location
                  WithBlock:(TBIULocationManagerGeoCodeUpdateBlock)block
                 errorBlock:(TBIULocationManagerGeoCodeUpdateFailBlock)errorBlock;
@end

@protocol TBIULocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(TBIULocationManager *)manager didFailWithError:(NSError *)error;

- (void)locationManager:(TBIULocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
@end

@protocol TBIULocationManagerGeoCoderDelegate <NSObject>

@optional
- (void)locationManager:(TBIULocationManager *)manager
       didFindPlacemark:(MKPlacemark *)placeMark;

- (void)      locationManager:(TBIULocationManager *)manager
didFailFindPlacemarkWithError:(NSError *)error;


@end

@protocol TBIULocationManagerPlacemarkParseDelegate <NSObject>

@optional
- (void)locationManager:(TBIULocationManager *)manager
 didFindLocationDetails:(NSArray *)details;

@end