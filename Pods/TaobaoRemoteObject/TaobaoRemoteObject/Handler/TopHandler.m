//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 下午4:17.
//


#import "TopHandler.h"
#import "TopInfo.h"
#import "TBRONSStringUtil.h"
#import "NSObject+TBIU_ToNSDictionary.h"
#import "NSString+TBHelper.h"
#import "RemoteEvent.h"
#import "NSDictionary+TBIU_ToObject.h"
#import "NSObject+TBIU_ToJson.h"
#import "TBIUJson.h"

#define TOP_RELEASE_HOST       @"http://gw.api.taobao.com/router/rest"
#define TOP_PRE_RELEASE_HOST   @"http://gw.api.taobao.com/router/rest"
#define TOP_DAILY_HOST         @"http://api.daily.taobao.net/router/rest"


@implementation TopHandler {

@private
    TaoBaoEnvironment _env;
    NSString *_host;
    NSString *_appKey;
    NSString *_appSecretKey;
    NSString *_customHost;
    NSString *_topSession;
}
@synthesize env = _env;
@synthesize appKey = _appKey;
@synthesize appSecretKey = _appSecretKey;
@synthesize customHost = _customHost;
@synthesize topSession = _topSession;

+ (TopHandler *)instance {
    static TopHandler *_instance = nil;

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
        _env = TBRO_ENV_Release;
        _host = TOP_RELEASE_HOST;
    }
    return self;
}

- (void)setEnv:(TaoBaoEnvironment)env {
    switch (env) {
        case (TBRO_ENV_Release):
            _env = TBRO_ENV_Release;
            _host = TOP_RELEASE_HOST;
            break;
        case (TBRO_ENV_PreRelease):
            _env = TBRO_ENV_PreRelease;
            _host = TOP_PRE_RELEASE_HOST;
            break;
        case (TBRO_ENV_Daily):
            _env = TBRO_ENV_Daily;
            _host = TOP_DAILY_HOST;
            break;
        default:
            break;
    }
}

- (NSString *)host {
    if ([TBRONSStringUtil isNotBlank:_customHost]) {
        return _customHost;
    } else {
        return _host;
    }
}

- (BOOL)preProcess:(RemoteContext *)context {
    TopInfo *info = (TopInfo *) context.info;
    //必要校验
    NSString *appKey = _appKey;
    NSString *appSecretKey = _appSecretKey;
    if ([TBRONSStringUtil isBlank:_appKey] || [TBRONSStringUtil isBlank:_appSecretKey]) {
        [context addErrorMessage:@"No Appkey or AppSecretKey"];
        return NO;
    }
    if (!info) {
        [context addErrorMessage:@"No Top Info"];
        return NO;
    }
    if (![info validate]) {
        [context addErrorMessage:@"Top Info Validate Failed"];
        return NO;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:info.method
               forKey:@"method"];
    [params setObject:info.fields
               forKey:@"fields"];
    [params setObject:info.version
               forKey:@"v"];
    [params setObject:appKey
               forKey:@"app_key"];
    NSString *topSession = info.topSession ? : self.topSession;
    if ([TBRONSStringUtil isNotBlank:topSession]) {
        [params setObject:topSession
                   forKey:@"session"];
    }
    [params setObject:context.clientInfo.timeForString
               forKey:@"timestamp"];
    [params setObject:@"json"
               forKey:@"format"];
    [params setObject:@"md5"
               forKey:@"sign_method"];
    if (context.parameter) {
        id param = [context.parameter toDictionaryOrArray];
        [params addEntriesFromDictionary:param];
    }
    [params addEntriesFromDictionary:context.extra];

    NSArray *sortedKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *paramString = [NSMutableString stringWithCapacity:120];
    for (id name in sortedKeys) {
        [paramString appendFormat:@"%@%@",
                                  name,
                                  [params valueForKey:name]];
    }
    NSString *sign = [[[NSString stringWithFormat:@"%@%@%@",
                                                  appSecretKey,
                                                  paramString,
                                                  appSecretKey] md5] uppercaseString];
    [params setObject:sign
               forKey:@"sign"];

    NSMutableArray *urlRequestArray = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                              key,
                                                              [value makeURLEncode:kCFStringEncodingUTF8]]];
    }
    NSString *urlRequestString = [urlRequestArray componentsJoinedByString:@"&"];

    NSURL *url = [NSURL URLWithString:[[self host] stringByAppendingFormat:@"?%@",
                                                                           urlRequestString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    context.internal = request;
    NSString *key = [self getMonitorKey:context];
    self.monitorFunction(TBRO_MONITOR_TOP, TBRO_MONITOR_REQUEST, key);
    return YES;
}


- (SuccessRemoteEvent *)createSuccessEvent:(RemoteContext *)context
                                   request:(NSURLRequest *)request
                                  response:(NSURLResponse *)response
                            responseObject:(id)responseObject {
    SuccessRemoteEvent *event = [super createSuccessEvent:context
                                                  request:request
                                                 response:response
                                           responseObject:responseObject];
    NSString *key = [self getMonitorKey:context];
    NSError *error = nil;
    if ([responseObject length] == 0) {
        TBRO_LOG(@"TOP return NULL");
        self.monitorFunction(TBRO_MONITOR_TOP, TBRO_MONITOR_REQUEST_FAILED, key);
        event.responseData = nil;
    } else {
        NSDictionary *dic = TBIUJSONDecode(responseObject, &error);
        if (dic) {
            self.monitorFunction(TBRO_MONITOR_TOP, TBRO_MONITOR_REQUEST_DONE, key);
            TBRO_LOG(@"TOP return [%@]", [dic toJSONString]);
            NSDictionary *errorResponse = [dic objectForKey:@"error_response"];
            if (errorResponse && [errorResponse objectForKey:@"code"]) {
                NSNumber *code = [errorResponse objectForKey:@"code"];
                if ([code integerValue] == 26 || [code integerValue] == 27) {
                    event.isSidInvalid = YES;
                    [[NSNotificationCenter defaultCenter]
                                           postNotificationName:TBRO_SID_INVALID_NOTIFICATION_NAME
                                                         object:self
                                                       userInfo:[NSDictionary dictionaryWithObject:context
                                                                                            forKey:TBRO_SID_INVALID_REMOTE_CONTEXT]];
                }
            }
            TopInfo *info = (TopInfo *) context.info;
            if (info.returnClass && dic && [dic respondsToSelector:@selector(toObjectWithClass:)]) {
                event.responseData = [dic toObjectWithClass:info.returnClass];
            } else {
                event.responseData = dic;
            }
        } else {
            self.monitorFunction(TBRO_MONITOR_TOP, TBRO_MONITOR_REQUEST_FAILED, key);
            if (error) {
                TBRO_LOG(@"TOP return error [%@]", error);
            }
            event.responseData = nil;
        }
    }
    [event.context addNSError:error];
    return event;
}

- (FailedRemoteEvent *)createFailedEvent:(RemoteContext *)context
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response
                                   error:(NSError *)error {
    NSString *key = [self getMonitorKey:context];
    self.monitorFunction(TBRO_MONITOR_TOP, TBRO_MONITOR_REQUEST_NETWORK_ERROR, key);
    return [super createFailedEvent:context
                            request:request
                           response:response
                              error:error];
}


- (NSString *)getMonitorKey:(RemoteContext *)context {
    TopInfo *topInfo = (TopInfo *) context.info;
    NSString *key = [NSString stringWithFormat:@"%@_%@",
                                               topInfo.method,
                                               topInfo.version];
    return key;
}


@end