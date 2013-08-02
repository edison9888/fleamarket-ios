//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-13 下午6:05.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>
#import "TBIULocationManager.h"
#import "TBIUChinaDivisionManager.h"
#import "TBIUChinaLocationTransform.h"

#define kDefaultUserDistanceFilter  kCLLocationAccuracyBestForNavigation
#define kDefaultUserDesiredAccuracy kCLLocationAccuracyBest

NSString *const TBIULocationManagerUserLocationDidChangeNotification =
        @"TBIULocationManagerUserLocationDidChangeNotification";
NSString *const TBIULocationManagerNotificationLocationUserInfoKey = @"newLocation";

NSString *const TBIULocationManagerPlacemarkNotification =
        @"TBIULocationManagerPlacemarkNotification";
NSString *const TBIULocationManagerNotificationPlacemarkUserInfoKey = @"Placemark";

NSString *const TBIULocationManagerLocationDetailNotification =
        @"TBIULocationManagerLocationDetailNotification";
NSString *const TBIULocationManagerNotificationLocationDetailUserInfoKey = @"locationDetail";

static char kTBIUMKReverseGeocoderSuccessBlockKey;

static char kTBIUMKReverseGeocoderFailedBlockKey;

@interface MKReverseGeocoder (TBIULocationManager)
@property(copy) TBIULocationManagerGeoCodeUpdateBlock successBlock;
@property(copy) TBIULocationManagerGeoCodeUpdateFailBlock failedBlock;
@end


@implementation MKReverseGeocoder (TBIULocationManager)
- (TBIULocationManagerGeoCodeUpdateBlock)successBlock {
    return objc_getAssociatedObject(self, &kTBIUMKReverseGeocoderSuccessBlockKey);
}

- (void)setSuccessBlock:(TBIULocationManagerGeoCodeUpdateBlock)successBlock {
    objc_setAssociatedObject(self, &kTBIUMKReverseGeocoderSuccessBlockKey, successBlock, OBJC_ASSOCIATION_COPY);
}

- (TBIULocationManagerGeoCodeUpdateFailBlock)failedBlock {
    return objc_getAssociatedObject(self, &kTBIUMKReverseGeocoderFailedBlockKey);
}

- (void)setFailedBlock:(TBIULocationManagerGeoCodeUpdateFailBlock)failedBlock {
    objc_setAssociatedObject(self, &kTBIUMKReverseGeocoderFailedBlockKey, failedBlock, OBJC_ASSOCIATION_COPY);
}

@end


@interface TBIULocationBlockWrap : NSObject
@property(copy) TBIULocationManagerLocationUpdateBlock successBlock;
@property(copy) TBIULocationManagerLocationUpdateFailBlock failedBlock;

- (id)initWithSuccessBlock:(TBIULocationManagerLocationUpdateBlock)successBlock
               failedBlock:(TBIULocationManagerLocationUpdateFailBlock)failedBlock;

+ (id)wrapWithSuccessBlock:(TBIULocationManagerLocationUpdateBlock)successBlock
               failedBlock:(TBIULocationManagerLocationUpdateFailBlock)failedBlock;

@end

@implementation TBIULocationBlockWrap
- (id)initWithSuccessBlock:(TBIULocationManagerLocationUpdateBlock)successBlock
               failedBlock:(TBIULocationManagerLocationUpdateFailBlock)failedBlock {
    self = [super init];
    if (self) {
        self.successBlock = successBlock;
        self.failedBlock = failedBlock;
    }

    return self;
}

+ (id)wrapWithSuccessBlock:(TBIULocationManagerLocationUpdateBlock)successBlock
               failedBlock:(TBIULocationManagerLocationUpdateFailBlock)failedBlock {
    return [[self alloc]
                  initWithSuccessBlock:successBlock
                           failedBlock:failedBlock];
}


@end

@interface TBIULocationManager () <CLLocationManagerDelegate, MKReverseGeocoderDelegate>

@property(nonatomic, readonly) CLLocationManager *userLocationManager;

@end

@implementation TBIULocationManager {
@private
    volatile BOOL _isUpdatingUserLocation;
    volatile BOOL _isOnlyOneUpdatingUserLocation;

    CLLocationManager *_userLocationManager;
    NSMutableArray *_locationRequests;
    CLLocation *_location;

    TBIUWeak id <TBIULocationManagerDelegate> _delegate;
    TBIUWeak id <TBIULocationManagerGeoCoderDelegate> _geoCoderDelegate;
    TBIUWeak id <TBIULocationManagerPlacemarkParseDelegate> _placemarkParseDelegate;

    CLGeocoder *_geocoder;
    MKReverseGeocoder *_reverseGeoCoder;

    BOOL _autoGrecoder;
    BOOL _autoParsePlacemark;
    BOOL _chinaLocationTransform;
}

@synthesize userLocationManager = _userLocationManager;
@synthesize delegate = _delegate;
@synthesize geoCoderDelegate = _geoCoderDelegate;
@synthesize autoGrecoder = _autoGrecoder;
@synthesize autoParsePlacemark = _autoParsePlacemark;
@synthesize placemarkParseDelegate = _placemarkParseDelegate;

@synthesize chinaLocationTransform = _chinaLocationTransform;

+ (TBIULocationManager *)instance {
    static TBIULocationManager *_instance = nil;
    static dispatch_once_t _oncePredicate_TBIULocationManager;

    dispatch_once(&_oncePredicate_TBIULocationManager, ^{
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
        _chinaLocationTransform = YES;
        _isUpdatingUserLocation = NO;
        _isOnlyOneUpdatingUserLocation = NO;
        _autoGrecoder = NO;
        _autoParsePlacemark = NO;
        _locationRequests = [NSMutableArray arrayWithCapacity:2];
        _userLocationManager = [[CLLocationManager alloc] init];
        _userLocationManager.distanceFilter = kDefaultUserDistanceFilter;
        _userLocationManager.desiredAccuracy = kDefaultUserDesiredAccuracy;
        _userLocationManager.delegate = self;
    }
    return self;
}

#pragma mark - 公用方法

+ (BOOL)locationServicesEnabled {
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    BOOL locating = YES;
    if (systemVersion >= 4.2) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            locating = YES;
        }
        else locating = NO;
    }

    if (systemVersion >= 4.0 && ![CLLocationManager locationServicesEnabled]) {
        locating = NO;
    }

    return locating;
}


+ (BOOL)significantLocationChangeMonitoringAvailable {
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

- (void)startUpdatingLocation {
    _isUpdatingUserLocation = YES;
    [self.userLocationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    _isUpdatingUserLocation = NO;
    [self.userLocationManager stopUpdatingLocation];
    NSArray *blocks;
    @synchronized (self) {
        blocks = [[NSArray alloc] initWithArray:_locationRequests];
        [_locationRequests removeAllObjects];
    }

    if (blocks.count > 0) {
        for (TBIULocationBlockWrap *wrap in blocks) {
            if (wrap.failedBlock)
                wrap.failedBlock(self, [NSError errorWithDomain:@"TBIULocationManager"
                                                           code:0
                                                       userInfo:[NSDictionary dictionaryWithObject:@"Canceled"
                                                                                            forKey:@"Reason"]]
                );
        }
    }
}

- (void)updateUserLocation {
    [self updateUserLocationWithBlock:NULL
                           errorBlock:NULL];
}


- (void)updateUserLocationWithBlock:(TBIULocationManagerLocationUpdateBlock)block
                         errorBlock:(TBIULocationManagerLocationUpdateFailBlock)errorBlock {
    if (block != NULL || errorBlock != NULL) {
        TBIULocationBlockWrap *blockWrap = [TBIULocationBlockWrap wrapWithSuccessBlock:block
                                                                           failedBlock:errorBlock];
        @synchronized (self) {
            [_locationRequests addObject:blockWrap];
        }
    }

    if (!_isUpdatingUserLocation && !_isOnlyOneUpdatingUserLocation) {
        _isOnlyOneUpdatingUserLocation = YES;
        [self.userLocationManager startUpdatingLocation];
    }

}



#pragma mark  - 定位相关
- (CLLocation *)lastLocation {
    return self.userLocationManager.location;
}

- (NSString *)purpose {
    return [self.userLocationManager.purpose copy];
}

- (void)setPurpose:(NSString *)purpose {
    self.userLocationManager.purpose = [purpose copy];
}

- (CLLocationDistance)userDistanceFilter {
    return self.userLocationManager.distanceFilter;
}

- (void)setUserDistanceFilter:(CLLocationDistance)userDistanceFilter {
    self.userLocationManager.distanceFilter = userDistanceFilter;
}

- (CLLocationAccuracy)userDesiredAccuracy {
    return self.userLocationManager.desiredAccuracy;
}

- (void)setUserDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy {
    self.userLocationManager.desiredAccuracy = userDesiredAccuracy;
}

#pragma mark -CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self needStop];
    @try {
        //delegate
        if (self.delegate
                && [self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
            [self.delegate locationManager:self
                       didUpdateToLocation:newLocation
                              fromLocation:oldLocation];
        }
        //Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:TBIULocationManagerUserLocationDidChangeNotification
                                                            object:self
                                                          userInfo:(
                                                                  [NSDictionary dictionaryWithObject:newLocation
                                                                                              forKey:TBIULocationManagerNotificationLocationUserInfoKey])];


        //Block
        NSArray *blocks;
        @synchronized (self) {
            blocks = [[NSArray alloc] initWithArray:_locationRequests];
            [_locationRequests removeAllObjects];
        }

        if (blocks.count > 0) {
            for (TBIULocationBlockWrap *wrap in blocks) {
                if (wrap.successBlock)
                    wrap.successBlock(self, newLocation, oldLocation);
            }
        }
        //自动进行位置信息匹配
        if (_autoGrecoder && newLocation && CLLocationCoordinate2DIsValid(newLocation.coordinate)) {
            [self geocodeUserLocation:newLocation.coordinate];
        }
    }
    @finally {
        _location = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations objectAtIndex:0];
    [self locationManager:manager
      didUpdateToLocation:newLocation
             fromLocation:_location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self needStop];
    @try {
        if (self.delegate
                && [self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [self.delegate locationManager:self
                          didFailWithError:error];
        }

        NSArray *blocks;
        @synchronized (self) {
            blocks = [[NSArray alloc] initWithArray:_locationRequests];
            [_locationRequests removeAllObjects];
        }

        if (blocks.count > 0) {
            for (TBIULocationBlockWrap *wrap in blocks) {
                if (wrap.failedBlock)
                    wrap.failedBlock(self, error);
            }
        }
    }
    @finally {
    }
}

- (void)needStop {
    if (!_isUpdatingUserLocation && _isOnlyOneUpdatingUserLocation) {
        NSUInteger requestCount = 0;
        @synchronized (self) {
            requestCount = _locationRequests.count;
        }
        if (requestCount == 0) {
            _isOnlyOneUpdatingUserLocation = NO;
            [self stopUpdatingLocation];
        }
    }
}


#pragma mark  -获取详细地址相关调用

- (void)geocodeUserLocation:(CLLocationCoordinate2D)location {
    [self geocodeUserLocation:location
                    WithBlock:NULL
                   errorBlock:NULL];
}

- (void)geocodeUserLocation:(CLLocationCoordinate2D)location
                  WithBlock:(TBIULocationManagerGeoCodeUpdateBlock)block
                 errorBlock:(TBIULocationManagerGeoCodeUpdateFailBlock)errorBlock {
    if (_chinaLocationTransform) {
        transformChinaLocationNoCopy(&location);
    }

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        if (_geocoder) {
            _geocoder = nil;
        }

        _geocoder = [[CLGeocoder alloc] init];

        CLLocation *cllocation = [[CLLocation alloc]
                                              initWithLatitude:location.latitude
                                                     longitude:location.longitude];

        [_geocoder reverseGeocodeLocation:cllocation
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            if (error || placemarks == nil) {
                                [self receivePlaceMarkError:error
                                            withFailedBlock:errorBlock];
                                return;
                            }
                            MKPlacemark *placemark = placemarks.count > 0 ? [placemarks objectAtIndex:0] : nil;
                            [self receivePlaceMark:placemark
                                  withSuccessBlock:block];
                        }];

    } else {
        if (_reverseGeoCoder) {
            _reverseGeoCoder.delegate = nil;
            _reverseGeoCoder.successBlock = NULL;
            _reverseGeoCoder.failedBlock = NULL;
            _reverseGeoCoder = nil;
        }

        _reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:location];
        _reverseGeoCoder.successBlock = block;
        _reverseGeoCoder.failedBlock = errorBlock;
        _reverseGeoCoder.delegate = self;
        [_reverseGeoCoder start];
    }

}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    TBIULocationManagerGeoCodeUpdateBlock block = geocoder.successBlock;
    geocoder.successBlock = NULL;
    [self receivePlaceMark:placemark
          withSuccessBlock:block];
}

- (void)receivePlaceMark:(MKPlacemark *)placemark withSuccessBlock:(TBIULocationManagerGeoCodeUpdateBlock)block {
    if (self.geoCoderDelegate
            && [self.geoCoderDelegate respondsToSelector:@selector(locationManager:didFindPlacemark:)]) {
        [self.geoCoderDelegate locationManager:self
                              didFindPlacemark:placemark];
    }

    //Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:TBIULocationManagerPlacemarkNotification
                                                        object:self
                                                      userInfo:(
                                                              [NSDictionary dictionaryWithObject:placemark
                                                                                          forKey:TBIULocationManagerNotificationPlacemarkUserInfoKey])];

    if (block) {
        block(self, placemark);
    }

    if (_autoParsePlacemark && self.placemarkParseDelegate && [self.placemarkParseDelegate
            respondsToSelector:@selector(locationManager:didFindLocationDetails:)]) {
        [[TBIUChinaDivisionManager instance]
                                   locationsWithPlacemark:placemark
                                               withResult:^(NSArray *details) {
                                                   [self.placemarkParseDelegate locationManager:self
                                                                         didFindLocationDetails:details];
                                                   //Notification
                                                   [[NSNotificationCenter defaultCenter]
                                                                          postNotificationName:TBIULocationManagerLocationDetailNotification
                                                                                        object:self
                                                                                      userInfo:(
                                                                                              [NSDictionary dictionaryWithObject:placemark
                                                                                                                          forKey:TBIULocationManagerNotificationLocationDetailUserInfoKey])];

                                               }];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    TBIULocationManagerGeoCodeUpdateFailBlock failBlock = geocoder.failedBlock;
    geocoder.failedBlock = NULL;
    [self receivePlaceMarkError:error
                withFailedBlock:failBlock];
}

- (void)receivePlaceMarkError:(NSError *)error withFailedBlock:(TBIULocationManagerGeoCodeUpdateFailBlock)block {
    if (self.geoCoderDelegate
            && [self.geoCoderDelegate respondsToSelector:@selector(locationManager:didFailFindPlacemarkWithError:)]) {
        [self.geoCoderDelegate locationManager:self
                 didFailFindPlacemarkWithError:error];
    }

    if (block) {
        block(self, error);
    }
}




#pragma mark  -dealloc
- (void)dealloc {
    if (_reverseGeoCoder) {
        _reverseGeoCoder.delegate = nil;
    }
    if (_userLocationManager) {
        _userLocationManager.delegate = nil;
    }
}


@end