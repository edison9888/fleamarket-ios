//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午4:57.
//


#import "ClientApiHandler.h"
#import "ClientApiInfo.h"
#import "NSObject+TBIU_ToJson.h"
#import "TBRONSStringUtil.h"
#import "NSString+TBHelper.h"
#import "PostData.h"
#import "RemoteEvent.h"
#import "NSDictionary+TBIU_ToObject.h"
#import "ClientApiBaseReturn.h"
#import "TBIUJson.h"

@interface ClientApiHandler ()
- (void)generatePostBodyWithKey:(id)key
                       postData:(PostData *)postData
                       boundary:(NSString **)boundary
                    contentType:(NSString **)contentType
                       postBody:(NSMutableData **)postBody;
@end

@implementation ClientApiHandler {
@private
    NSString *_signKey;
    BOOL _needDebugInfo;
    NSString *_forceHttpHeadHost;
    NSString *_sid;
}
@synthesize signKey = _signKey;
@synthesize needDebugInfo = _needDebugInfo;
@synthesize forceHttpHeadHost = _forceHttpHeadHost;


@synthesize sid = _sid;

+ (ClientApiHandler *)instance {
    static ClientApiHandler *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

#define SEPARATOR  @"&"

- (NSString *)signWithApi:(NSString *)api
           AndWithVersion:(NSString *)version
              AndWithImei:(NSString *)imei
              AndWithImsi:(NSString *)imsi
              AndWithData:(NSString *)data
              AndWithTime:(NSString *)time
                AndWithIp:
                        (NSString *)ip
           AndWithSignKey:(NSString *)signKey {
    NSUInteger cap = api.length + version.length + imei.length + imsi.length + 32 + time.length + ip.length
            + signKey.length + 7;
    NSMutableString *signString = [[NSMutableString alloc] initWithCapacity:cap];
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
    [signString appendString:SEPARATOR];
    if (ip) {
        [signString appendString:ip];
        [signString appendString:SEPARATOR];
    }
    [signString appendString:[TBRONSStringUtil safeConvertString:signKey]];
    return [signString md5];
}

- (BOOL)preProcess:(RemoteContext *)context {
    ClientApiInfo *info = (ClientApiInfo *) context.info;
    //必要校验
    if (!info) {
        [context addErrorMessage:@"No Client Info"];
        return NO;
    }
    if (![info validate]) {
        [context addErrorMessage:@"Client Info Validate Failed"];
        return NO;
    }
    //获取参数
    NSString *host = info.host;
    NSString *api = info.api;
    NSString *version = info.version;
    NSString *signKey = info.signKey ? : self.signKey;
    NSString *sid = info.sid ? : self.sid;
    NSString *token = info.token;
    NSString *imei = context.clientInfo.imei;
    NSString *imsi = context.clientInfo.imsi;
    NSString *ttid = context.clientInfo.ttid;
    NSString *ip = info.needSignWithIp ? context.clientInfo.ip : nil;
    NSString *time = [NSString stringWithFormat:@"%lld",
                                                (long long int) ([context.clientInfo.time timeIntervalSince1970] *
                                                        1000)];
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
                             AndWithIp:ip
                        AndWithSignKey:signKey];
    context.internal = ([self getRequest:info
                                    host:host
                                     api:api
                                 version:version
                                     sid:sid
                                   token:token
                                    imei:imei
                                    imsi:imsi
                                    ttid:ttid
                                      ip:ip
                                    time:time
                                    data:data
                                    sign:sign
                                deviceId:deviceId
                                   extra:context.extra]);
    NSString *key = [self getMonitorKey:context];
    self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST, key);
    return YES;
}


#define ADD_TO_URL_REQUEST_ARRAY(key,array)     \
         if ([TBRONSStringUtil isNotBlank:(key)]) {    \
            [array addObject:[NSString stringWithFormat:@"%@=%@", @#key ,           \
            [key makeURLEncode:kCFStringEncodingUTF8]]];                                 \
         }

#define POST_BOUNDARY @"*****com.taobao.remote.object.form.boundary"

- (NSMutableURLRequest *)getRequest:(ClientApiInfo *)info
                               host:(NSString *)host
                                api:(NSString *)api
                            version:(NSString *)version
                                sid:(NSString *)sid
                              token:(NSString *)token
                               imei:(NSString *)imei
                               imsi:(NSString *)imsi
                               ttid:(NSString *)ttid
                                 ip:(NSString *)ip
                               time:(NSString *)time
                               data:(NSString *)data
                               sign:(NSString *)sign
                           deviceId:(NSString *)deviceId
                              extra:(NSMutableDictionary *)extra {
    NSMutableArray *urlRequestArray = [[NSMutableArray alloc] initWithCapacity:10];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"api",
                                                          [api makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"v",
                                                          [version makeURLEncode:kCFStringEncodingUTF8]]];
    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                          @"t",
                                                          [time makeURLEncode:kCFStringEncodingUTF8]]];
    ADD_TO_URL_REQUEST_ARRAY(sid, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(token, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(ttid, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(imei, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(imsi, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(ip, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(sign, urlRequestArray)
    ADD_TO_URL_REQUEST_ARRAY(deviceId, urlRequestArray)

    __block BOOL needPost = NO;
    __block NSString *boundary = nil;
    __block NSString *contentType = nil;
    __block NSMutableData *postBody = nil;
    [extra enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSArray class]] && ![obj isKindOfClass:[PostData class]]) {
            [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                                  [key description],
                                                                  [[obj description]
                                                                        makeURLEncode:kCFStringEncodingUTF8]]];
        } else if ([obj isKindOfClass:[PostData class]]) {
            needPost = YES;
            [self generatePostBodyWithKey:key
                                 postData:obj
                                 boundary:&boundary
                              contentType:&contentType
                                 postBody:&postBody];
        } else {
            //it s NSArray
            for (id o in obj) {
                if (![o isKindOfClass:[PostData class]]) {
                    [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                                          [key description],
                                                                          [[o description]
                                                                              makeURLEncode:kCFStringEncodingUTF8]]];
                } else {
                    needPost = YES;
                    [self generatePostBodyWithKey:key
                                         postData:o
                                         boundary:&boundary
                                      contentType:&contentType
                                         postBody:&postBody];
                }
            }
        }
    }];

    if (_needDebugInfo || info.needDebugInfo) {
        [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                              @"isDebug",
                                                              @"1"]];
    }
    if (info.forcePost) {
        needPost = YES;
        PostData *postData = [[PostData alloc] init];
        postData.fileData = [data dataUsingEncoding:NSUTF8StringEncoding];
        [self generatePostBodyWithKey:@"data"
                             postData:postData
                             boundary:&boundary
                          contentType:&contentType
                             postBody:&postBody];
        if ([TBRONSStringUtil isNotBlank:(info.fields)]) {
            PostData *fieldPostData = [[PostData alloc] init];
            fieldPostData.fileData = [info.fields dataUsingEncoding:NSUTF8StringEncoding];
            [self generatePostBodyWithKey:@"fields"
                                 postData:fieldPostData
                                 boundary:&boundary
                              contentType:&contentType
                                 postBody:&postBody];

        }
    } else {
        [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                              @"data",
                                                              [data makeURLEncode:kCFStringEncodingUTF8]]];
        if ([TBRONSStringUtil isNotBlank:(info.fields)]) {
            [urlRequestArray addObject:[NSString stringWithFormat:@"%@=%@",
                                                                  @"fields",
                                                                  [info.fields makeURLEncode:kCFStringEncodingUTF8]]];
        }
    }

    NSString *urlRequestString = [urlRequestArray componentsJoinedByString:@"&"];
    NSURL *url = [NSURL URLWithString:[host stringByAppendingFormat:@"?%@",
                                                                    urlRequestString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (needPost) {
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",
                                                         boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        [request addValue:contentType
       forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postBody];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    if ([TBRONSStringUtil isNotBlank:info.forceHttpHeadHost]) {
        [request addValue:info.forceHttpHeadHost
       forHTTPHeaderField:@"Host"];
    } else if ([TBRONSStringUtil isNotBlank:_forceHttpHeadHost]) {
        [request addValue:_forceHttpHeadHost
       forHTTPHeaderField:@"Host"];
    }
    return request;
}

- (void)generatePostBodyWithKey:(id)key
                       postData:(PostData *)postData
                       boundary:(NSString **)boundary
                    contentType:(NSString **)contentType
                       postBody:(NSMutableData **)postBody {
    if (!(*postBody)) {
        (*postBody) = [NSMutableData data];
        (*boundary) = [NSString stringWithFormat:@"%@%u",
                                                 POST_BOUNDARY,
                                                 arc4random()];
        (*contentType) = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                                                    *boundary];
    }

    [*postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",
                                                      *boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    if (postData.fileName)
        [*postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; "
                                                                  "filename=\"%@\"\r\n",
                                                          key,
                                                          postData.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    else
        [*postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",
                                                          key] dataUsingEncoding:NSUTF8StringEncoding]];


    if (postData.contentType)
        [*postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",
                                                          postData.contentType]
                                                          dataUsingEncoding:NSUTF8StringEncoding]];
    else
        [*postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [*postBody appendData:postData.fileData];
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
        self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST_FAILED, key);
        TBRO_LOG(@"ClientAPI return NULL");
        event.responseData = nil;
    } else {
        NSDictionary *dic = TBIUJSONDecode(responseObject, &error);

        if (dic) {
            TBRO_LOG(@"ClientAPI return [%@]", [dic toJSONString]);
            ClientApiBaseReturn *baseReturn = [dic toObjectWithClass:[ClientApiBaseReturn class]];
            if (baseReturn.ret == TBRO_CLIENT_UNAUTHORIZED) {
                event.isSidInvalid = YES;
                [[NSNotificationCenter defaultCenter]
                                       postNotificationName:TBRO_SID_INVALID_NOTIFICATION_NAME
                                                     object:self
                                                   userInfo:[NSDictionary dictionaryWithObject:context
                                                                                        forKey:TBRO_SID_INVALID_REMOTE_CONTEXT]];
            }
            ClientApiInfo *info = (ClientApiInfo *) context.info;
            if (info.returnClass && baseReturn.data) {
                if ([baseReturn.data respondsToSelector:@selector(toObjectWithClass:)]) {
                    baseReturn.data = [baseReturn.data toObjectWithClass:info.returnClass];
                }
            }

            if (baseReturn.ret == TBRO_CLIENT_OK) {
                self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST_DONE, key);
            } else {
                self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST_FAILED, key);
            }
            event.responseData = baseReturn;
        } else {
            if (error) {
                TBRO_LOG(@"ClientAPI return error [%@]", error);
            }
            self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST_FAILED, key);
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
    self.monitorFunction(TBRO_MONITOR_CLIENT_API, TBRO_MONITOR_REQUEST_NETWORK_ERROR, key);
    return [super createFailedEvent:context
                            request:request
                           response:response
                              error:error];
}

- (NSString *)getMonitorKey:(RemoteContext *)context {
    ClientApiInfo *apiInfo = (ClientApiInfo *) context.info;
    NSString *key = [NSString stringWithFormat:@"%@_%@",
                                               apiInfo.api,
                                               apiInfo.version];
    return key;
}


@end