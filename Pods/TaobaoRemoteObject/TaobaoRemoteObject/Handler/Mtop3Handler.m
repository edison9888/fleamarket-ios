//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午11:23.
//


#import "Mtop3Handler.h"
#import "MtopInfo.h"
#import "NSObject+TBIU_ToJson.h"
#import "TBRONSStringUtil.h"
#import "NSString+TBHelper.h"
#import "RemoteEvent.h"
#import "MtopBaseReturn.h"
#import "NSDictionary+TBIU_ToObject.h"
#import "TBIUJson.h"

#define MTOP3_RELEASE_HOST      @"http://api.m.taobao.com/rest/api3.do"
#define MTOP3_PRE_RELEASE_HOST   @"http://api.wapa.taobao.com/rest/api3.do"
#define MTOP3_DAILY_HOST        @"http://api.waptest.taobao.com/rest/api3.do"

@implementation Mtop3Handler {

@private
    NSString *_host;
    TaoBaoEnvironment _env;
    NSString *_appKey;
    NSString *_appSecretKey;
    NSString *_customHost;
}
@synthesize env = _env;
@synthesize appKey = _appKey;
@synthesize appSecretKey = _appSecretKey;
@synthesize customHost = _customHost;


+ (Mtop3Handler *)instance {
    static Mtop3Handler *_instance = nil;

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
        _host = MTOP3_RELEASE_HOST;
    }
    return self;
}

- (void)setEnv:(TaoBaoEnvironment)env {
    switch (env) {
        case (TBRO_ENV_Release):
            _env = TBRO_ENV_Release;
            _host = MTOP3_RELEASE_HOST;
            break;
        case (TBRO_ENV_PreRelease):
            _env = TBRO_ENV_PreRelease;
            _host = MTOP3_PRE_RELEASE_HOST;
            break;
        case (TBRO_ENV_Daily):
            _env = TBRO_ENV_Daily;
            _host = MTOP3_DAILY_HOST;
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

#define SEPARATOR  @"&"

- (NSString *)signWithApi:(NSString *)api
           AndWithVersion:(NSString *)version
              AndWithImei:(NSString *)imei
              AndWithImsi:(NSString *)imsi
              AndWithData:(NSString *)data
              AndWithTime:(NSString *)time
            AndWithAppKey:(NSString *)appKey
      AndWithAppSecretKey:(NSString *)appSecretKey
             AndWithEcode:(NSString *)ecode {
    NSUInteger cap = api.length + version.length + imei.length + imsi.length + 32 + time.length + _appSecretKey
            .length + 32
            + ecode.length + 8;
    NSMutableString *signString = [[NSMutableString alloc] initWithCapacity:cap];
    if (ecode) {
        [signString appendString:[TBRONSStringUtil safeConvertString:ecode]];
        [signString appendString:SEPARATOR];
    }
    [signString appendString:[TBRONSStringUtil safeConvertString:appSecretKey]];
    [signString appendString:SEPARATOR];
    [signString appendString:[[TBRONSStringUtil safeConvertString:appKey] md5]];
    [signString appendString:SEPARATOR];
    [signString appendString:[TBRONSStringUtil safeConvertString:api]];
    [signString appendString:SEPARATOR];
    [signString appendString:[TBRONSStringUtil safeConvertString:version]];
    [signString appendString:SEPARATOR];
    [signString appendString:[TBRONSStringUtil safeConvertString:imei]];
    [signString appendString:SEPARATOR];
    [signString appendString:[TBRONSStringUtil safeConvertString:imsi]];
    [signString appendString:SEPARATOR];
    [signString appendString:[[TBRONSStringUtil safeConvertString:data] md5]];
    [signString appendString:SEPARATOR];
    [signString appendString:[TBRONSStringUtil safeConvertString:time]];
    return [signString md5];
}

#define ADD_TO_URL_REQUEST_ARRAY(key,array)     \
         if ([TBRONSStringUtil isNotBlank:(key)]) {    \
            [array addObject:[NSString stringWithFormat:@"%@=%@", @#key ,           \
            [key makeURLEncode:kCFStringEncodingUTF8]]];                                 \
         }

- (NSMutableURLRequest *)getRequestWith:(NSString *)api
                                version:(NSString *)version
                                    sid:(NSString *)sid
                                  token:(NSString *)token
                                   imei:(NSString *)imei
                                   imsi:(NSString *)imsi
                                   ttid:(NSString *)ttid
                                   time:(NSString *)time
                                   data:(NSString *)data
                                 appKey:(NSString *)appKey
                                   sign:(NSString *)sign
                               deviceId:(NSString *)deviceId {
    NSMutableArray *urlRequestArray = [[NSMutableArray alloc] initWithCapacity:5];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"api",
                                                          [api makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"v",
                                                          [version makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"data",
                                                          [data makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"t",
                                                          [time makeURLEncode:kCFStringEncodingUTF8]]];

    ADD_TO_URL_REQUEST_ARRAY(sid, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(token, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(ttid, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(imei, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(imsi, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(deviceId, urlRequestArray)
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"appKey",
                                                          [appKey makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"sign",
                                                          [sign makeURLEncode:kCFStringEncodingUTF8]]];
    NSString *urlRequestString = [urlRequestArray componentsJoinedByString:@"&"];
    NSURL *url = [NSURL URLWithString:[[self host] stringByAppendingFormat:@"?%@",
                                                                           urlRequestString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    return request;
}


- (BOOL)preProcess:(RemoteContext *)context {
    MtopInfo *info = (MtopInfo *) context.info;
    //必要校验
    NSString *appKey = _appKey;
    NSString *appSecretKey = _appSecretKey;
    if ([TBRONSStringUtil isBlank:_appKey] || [TBRONSStringUtil isBlank:_appSecretKey]) {
        [context addErrorMessage:@"No Appkey or AppSecretKey"];
        return NO;
    }
    if (!info) {
        [context addErrorMessage:@"No Mtop Info"];
        return NO;
    }
    if (![info validate]) {
        [context addErrorMessage:@"Mtop Info Validate Failed"];
        return NO;
    }

    NSString *api = info.api;
    NSString *version = info.version;
    NSString *token = info.token;
    NSString *sid = info.sid ? : self.sid;
    NSString *ecode = info.ecode;
    NSString *imei = context.clientInfo.imei;
    NSString *imsi = context.clientInfo.imsi;
    NSString *ttid = context.clientInfo.ttid;
    NSString *time = [NSString stringWithFormat:@"%ld",
                                                (long) [context.clientInfo.time timeIntervalSince1970]];
    NSString *deviceId = context.clientInfo.deviceId;

    NSString *data;
    if (context.parameter) {
        data = [context.parameter toJSONString];
    } else {
        data = @"{}";
    }
    NSString *sign = [self signWithApi:api
                        AndWithVersion:version
                           AndWithImei:imei
                           AndWithImsi:imsi
                           AndWithData:data
                           AndWithTime:time
                         AndWithAppKey:appKey
                   AndWithAppSecretKey:appSecretKey
                          AndWithEcode:ecode];

    context.internal = [self getRequestWith:api
                                    version:version
                                        sid:sid
                                      token:token
                                       imei:imei
                                       imsi:imsi
                                       ttid:ttid
                                       time:time
                                       data:data
                                     appKey:appKey
                                       sign:sign
                                   deviceId:deviceId];
    NSString *key = [self getMonitorKey:context];
    self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST, key);
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
        TBRO_LOG(@"Mtop3 return NULL");
        event.responseData = nil;
        self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST_FAILED, key);
    } else {
        NSDictionary *dic = TBIUJSONDecode(responseObject, &error);
        if (dic) {
            TBRO_LOG(@"Mtop3 return:[%@]", [dic toJSONString]);
            MtopBaseReturn *baseReturn = [dic toObjectWithClass:[MtopBaseReturn class]];
            if ([@"ERR_SID_INVALID" isEqualToString:[baseReturn getRetCodeAtIndex:0]]) {
                event.isSidInvalid = YES;
                [[NSNotificationCenter defaultCenter]
                                       postNotificationName:TBRO_SID_INVALID_NOTIFICATION_NAME
                                                     object:self
                                                   userInfo:[NSDictionary dictionaryWithObject:context
                                                                                        forKey:TBRO_SID_INVALID_REMOTE_CONTEXT]];
            }
            MtopInfo *info = (MtopInfo *) context.info;
            if (info.returnClass && baseReturn.data) {
                if ([baseReturn.data respondsToSelector:@selector(toObjectWithClass:)]) {
                    baseReturn.data = [baseReturn.data toObjectWithClass:info.returnClass];
                }
            }
            if ([@"SUCCESS" isEqualToString:[baseReturn getRetCodeAtIndex:0]]) {
                self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST_DONE, key);
            } else {
                self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST_FAILED, key);
            }
            event.responseData = baseReturn;
        } else {
            if (error) {
                TBRO_LOG(@"Mtop3 return error [%@]", error);
            }
            self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST_FAILED, key);
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
    self.monitorFunction(TBRO_MONITOR_MTOP, TBRO_MONITOR_REQUEST_NETWORK_ERROR, key);
    return [super createFailedEvent:context
                            request:request
                           response:response
                              error:error];
}


- (NSString *)getMonitorKey:(RemoteContext *)context {
    MtopInfo *mtopInfo = (MtopInfo *) context.info;
    NSString *key = [NSString stringWithFormat:@"%@_%@",
                                               mtopInfo.api,
                                               mtopInfo.version];
    return key;
}


@end