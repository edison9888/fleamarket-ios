//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午11:32.
//


#import <iOS_Util/NSDictionary+TBIU_ToObject.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <TBSDK/TBSDKAccountInfo.h>
#import <MapKit/MapKit.h>
#import <objc/message.h>
#import <SDWebImage/SDWebImageManager.h>
#import <iOS_Util/TBIUCache.h>
#import "FMApplication.h"
#import "TBSDKConfiguration.h"
#import "FMUser.h"
#import "ClientInfo.h"
#import "FMLocation.h"
#import "FMSetting.h"
#import "TBMBGlobalFacade.h"
#import "ClientApiHandler.h"
#import "FMLastPostInfo.h"
#import "Mtop3Handler.h"
#import "TopHandler.h"
#import "FMUserTrack.h"
#import "FMPreference.h"
#import "NSObject+TBIU_ToNSDictionary.h"
#import "UIImage+TBIU_Webp.h"
#import "FMLoginService.h"
#import "UIAlertView+BlocksKit.h"
#import "TBSDKSSOLoginEngine.h"
#import "FMVersionService.h"
#import "TBROSync.h"
#import "FMCacheObject.h"
#import "UIDevice+TBHelper.h"
#import "WXApi.h"
#import "TBSocialShareConfig.h"
#import "FMMessageTimer.h"
#import "FMMessageDAO.h"
#import "UT.h"
#import "FMNotificationCommand.h"
#import "FMWindowShower.h"


@interface FMApplication () <TBSDKSSOLoginEngineDelegate, TBIULocationManagerDelegate, TBIULocationManagerGeoCoderDelegate, TBIULocationManagerPlacemarkParseDelegate>
@end

@implementation FMApplication {

@private
    FMUser *_loginUser;
    FMSetting *_setting;
    FMLocation *_location;
    FMLastPostInfo *_lastPostInfo;
    NSMutableDictionary *_postQueues;

    FMCacheObject *_cacheObject;
}
@synthesize loginUser = _loginUser;

@synthesize setting = _setting;

@synthesize location = _location;

@synthesize lastPostInfo = _lastPostInfo;

@synthesize postQueues = _postQueues;

+ (FMApplication *)instance {
    static FMApplication *_instance = nil;
    static dispatch_once_t _oncePredicate_FMApplication;

    dispatch_once(&_oncePredicate_FMApplication, ^{
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
        _loginUser = [[FMUser alloc] init];
        _setting = [[FMSetting alloc] init];
        _location = [[FMLocation alloc] init];
        [[NSNotificationCenter defaultCenter]
                               addObserver:self
                                  selector:@selector(whenSidInvalid:)
                                      name:TBRO_SID_INVALID_NOTIFICATION_NAME
                                    object:nil];
    }

    return self;
}

#pragma mark -- 初始化
- (void)systemInit {
    [[TBMBGlobalFacade instance] registerCommandAutoAsync];
    [UIImage supportWebP];
    [self UserTrack_init];
    [self TBSDK_init];
    [self RemoteObject_init];
    [self loadFromPreference];

    [self initShare];

    [[FMMessageTimer instance] initFMMessageTimer];
    [[FMMessageDAO instance] initMessageDB];
}

- (void)RemoteObject_init {
    [ClientInfo instance].ttid = kCurrentTTID;
    [ClientInfo instance].imei = [[UIDevice currentDevice] getUniqueGlobalDeviceIdentifier];
    [ClientInfo instance].imsi = [[UIDevice currentDevice] getUniqueGlobalDeviceIdentifier];
    [ClientInfo instance].deviceId = [[TBSDKConfiguration shareInstance] deviceID];

#ifdef TEST_ENV
    [ClientApiHandler instance].needDebugInfo = YES;
#endif
#ifdef PREPARE_SERVER_TEST
    [ClientApiHandler instance].forceHttpHeadHost = @"api.ershou.taobao.com";
#endif
    [[ClientApiHandler instance] setSignKey:API_ERSHOU_SECRET_KEY];
    [ClientApiHandler instance].schedulingStrategy = TBRO_Queue;
    [ClientApiHandler instance].monitorFunction = self.getMonitorFunction;

    ([TopHandler instance]).appKey = APP_KEY;
    ([TopHandler instance]).appSecretKey = APP_SECRET_KEY;
    ([TopHandler instance]).env = TOP_ENV;
    [TopHandler instance].schedulingStrategy = TBRO_Queue;
    [TopHandler instance].monitorFunction = self.getMonitorFunction;

    ([Mtop3Handler instance]).appKey = APP_KEY;
    ([Mtop3Handler instance]).appSecretKey = APP_SECRET_KEY;
    ([Mtop3Handler instance]).env = TOP_ENV;
    [Mtop3Handler instance].schedulingStrategy = TBRO_Queue;
    [Mtop3Handler instance].monitorFunction = self.getMonitorFunction;

    [HttpHandler instance].schedulingStrategy = TBRO_Queue;
}


- (void)UserTrack_init {
    //UserTrack启动
    [UT preInit];
    [UT setChannel:TA_CHANNEL];
    [UT setKey:APP_KEY
     appSecret:APP_SECRET_KEY];
    [UT turnOnGlobalNavigationTrack:nil];

//#ifdef TEST_ENV
//    [UT turnOnDebug];
//#endif

    //记录下面api调用的情况
    [UT bindPageName:
                [NSDictionary dictionaryWithObjectsAndKeys:@"API", NSStringFromClass([self class]),
                                                           nil]];


    [UT init];
}

- (void)TBSDK_init {
    TBSDKConfiguration *configuration = [TBSDKConfiguration shareInstance];
    configuration.wapTTID = kCurrentTTID;
    configuration.appKey = APP_KEY;
    configuration.appSecret = APP_SECRET_KEY;
    configuration.environment = TBSDKNETWORKENV;
}

- (TBROMonitorFunction)getMonitorFunction {
    return ^(TBROMonitorType type, TBROMonitorState state, NSString *key) {
        NSString *end = @"";
        switch (state) {
            case TBRO_MONITOR_REQUEST:
                return;
            case TBRO_MONITOR_REQUEST_DONE:
                return;
            case TBRO_MONITOR_REQUEST_FAILED:
                end = @"__FAILED";
                break;
            case TBRO_MONITOR_REQUEST_NETWORK_ERROR:
                end = @"__NETWORK_ERROR";
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [FMUserTrack ctrlClicked:[NSString stringWithFormat:@"%@%@",
                                                                key,
                                                                end]
                              onPage:self];
        }
        );
    };
}

- (void)loadFromPreference {
    NSDictionary *constantCache = (id) [FMPreference cacheByKey:CONSTANT_CACHE];
    if (nil != constantCache) {
        _cacheObject = [constantCache toObjectWithClass:[FMCacheObject class]];
        _cacheObject.user = _cacheObject.user ? : [[FMUser alloc] init];
        _cacheObject.setting = _cacheObject.setting ? : [[FMSetting alloc] init];
        _cacheObject.location = _cacheObject.location ? : [[FMLocation alloc] init];
        _cacheObject.lastPostInfo = _cacheObject.lastPostInfo ? : [[FMLastPostInfo alloc] init];
        _cacheObject.postQueues = _cacheObject.postQueues ? : [[NSMutableDictionary alloc] init];
        _loginUser = _cacheObject.user;
        _setting = _cacheObject.setting;
        _location = _cacheObject.location;
        _lastPostInfo = _cacheObject.lastPostInfo;
        _postQueues = _cacheObject.postQueues;
    }
}

- (void)initShare {
    [TBSocialShareConfig instance].tbSinaAppKey = TBSinaAppKey;
    [TBSocialShareConfig instance].tbSinaAppSecret = TBSinaAppSecret;
    [TBSocialShareConfig instance].tbSinaAppRedirectURI = TBSinaAppRedirectURI;
    [TBSocialShareConfig instance].tbWeChatAppID = TBWeChatAppID;

    [TBSocialShareConfig instance].tbDoubanAppKey = TBDoubanAppKey;
    [TBSocialShareConfig instance].tbDoubanAppSecret = TBDoubanAppSecret;
    [TBSocialShareConfig instance].tbDoubanAppRedirectURI = TBDoubanAppRedirectURI;


    //向微信注册
    [WXApi registerApp:TBWeChatAppID];
}
#pragma mark -- App退出时的一些操作
- (void)destroy {
    [self saveToPreference];
    [UT uninit];
}

#pragma mark -- App 刚启动后的一些操作
- (void)applicationDidStart:(NSDictionary *)launchOptions {
    [FMWindowShower instance];  //这样就可以接受消息了
    [[FMLoginService proxyObject] autoLogin:^(FMLoginResponse *loginResponse) {
        TBSDKSSOLoginEngine *loginEngine = [TBSDKSSOLoginEngine shareInstance];
        loginEngine.delegate = self;
        [loginEngine startSSO];
        if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
            FMLOG(@"launch with remote notification:[%@]", launchOptions);
            NSString *key = [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"key"];
            [FMNotificationCommand fromPush:key ? : @""];
        }
    }];

    [self autoUpdate];
    [[TBROSync instance]
               startWithHost:API_ERSHOU_HOST
                         api:@"internal.get.server.info"
                     version:@"1"
               needSyncFirst:NO];
    [self performSelector:@selector(registerAutoLogin)
               withObject:nil
               afterDelay:2];


    FMLOG(@"HasLocationOn [%d]", [TBIULocationManager locationServicesEnabled]);

    TBIULocationManager *locationManager = [TBIULocationManager instance];
    [locationManager setUserDistanceFilter:200.0f];
    [locationManager setUserDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    locationManager.autoGrecoder = YES;
    locationManager.autoParsePlacemark = YES;
    locationManager.delegate = self;
    locationManager.geoCoderDelegate = self;
    locationManager.placemarkParseDelegate = self;
    [locationManager updateUserLocation];
}

- (void)registerAutoLogin {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoLogin)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

- (void)autoLogin {
    [[FMLoginService proxyObject] autoLogin:NULL];
}


- (void)autoUpdate {
    [[FMVersionService proxyObject] getNewVersion:^(NewVersionInfo *info) {
        if (info.hasNewVersion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [UIAlertView alertViewWithTitle:@"提示"
                                                             message:@"有新版本哦，快去更新体验吧"];
                [alert setCancelButtonWithTitle:@"以后再说"
                                        handler:NULL];
                [alert addButtonWithTitle:@"立即更新"
                                  handler:^{
                                      if ([info.itemUrl length] < 1) {
                                          return;
                                      }
                                      NSURL *url = [NSURL URLWithString:[info.itemUrl copy]];
                                      [[UIApplication sharedApplication] openURL:url];
                                  }];
                [alert show];

            }
            );
        }
    }
    ];
}

- (NSString *)currentSSOLoginAccountName {
    return [[[TBSDKConfiguration shareInstance] accountInfo] nick];
}

- (void)currentIsSSOLogout:(BOOL)isLogout {

}


static NSUInteger sidInvalidTimes = 0;
#define MAX_SID_INVALID_TIME (10)
#pragma mark  -监听当sid失效时
- (void)whenSidInvalid:(NSNotification *)notification {
    RemoteContext *context = [notification.userInfo objectForKey:TBRO_SID_INVALID_REMOTE_CONTEXT];
    [[FMLoginService proxyObject] autoLogin:^(FMLoginResponse *loginResponse) {
        if (loginResponse.isSuccess && sidInvalidTimes < MAX_SID_INVALID_TIME) {
            sidInvalidTimes++;
            [context request];
        } else {
            sidInvalidTimes = 0;
            [FMLoginService logout];
            [[[FMWindowShower instance] proxyObject] retryLoginAndRequest:context];
        }
    }];

}


#pragma mark  -保存配置
- (void)saveToPreference {
    NSMutableDictionary *cacheDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [cacheDic addEntriesFromDictionary:[_cacheObject toDictionaryOrArray]];
    [FMPreference setDiskObject:cacheDic
                         ForKey:CONSTANT_CACHE];
}

- (void)asyncSaveToPreference {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self saveToPreference];
    }
    );
}

#pragma mark  - 更新位置

- (void)updateLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        TBIULocationManager *locationManager = [TBIULocationManager instance];
        [locationManager updateUserLocation];
    }
    );
}

- (void)updateLocationWithBlock:(TBIULocationManagerLocationUpdateBlock)block
                     errorBlock:(TBIULocationManagerLocationUpdateFailBlock)errorBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        TBIULocationManager *locationManager = [TBIULocationManager instance];
        [locationManager updateUserLocationWithBlock:block
                                          errorBlock:errorBlock];
    }
    );
}

- (void)cleanDiskCache {
    [[SDImageCache sharedImageCache] clearDisk];
    [[TBIUCache instance] clearDisk];
}

- (unsigned long long)getDiskCacheCount {
    return ([[SDImageCache sharedImageCache] getSize] + [[TBIUCache instance] getSize]);

}


- (void)locationManager:(TBIULocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation && CLLocationCoordinate2DIsValid(newLocation.coordinate)) {
        self.location.lat = [NSString stringWithFormat:@"%f",
                                                       newLocation.coordinate.latitude];
        self.location.lng = [NSString stringWithFormat:@"%f",
                                                       newLocation.coordinate.longitude];
        [self asyncSaveToPreference];
        [UT updateGPSInfo:@"Application"
                longitude:newLocation.coordinate.longitude
                 latitude:newLocation.coordinate.latitude];
    }
}

- (void)locationManager:(TBIULocationManager *)manager didFindPlacemark:(MKPlacemark *)placeMark {
    FMLOG(@"PlaceMark[%@]", placeMark);
}

- (void)locationManager:(TBIULocationManager *)manager didFindLocationDetails:(NSArray *)details {
    if (details.count > 0) {
        id detail = [details objectAtIndex:0];
        self.location.province = objc_msgSend(detail, @selector(province));
        self.location.city = objc_msgSend(detail, @selector(city));
        self.location.area = objc_msgSend(detail, @selector(district));
        self.location.locationId = [NSNumber numberWithInteger:(NSInteger) objc_msgSend(detail, @selector(locationID))];
        [self asyncSaveToPreference];
        TBMBGlobalSendNotificationForSELWithBody(@selector($$updateLocationSuccessNotification:location:), self.location);
    }
}


@end