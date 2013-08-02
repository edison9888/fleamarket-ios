//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-3 上午10:15.
//


#import "FMVersionService.h"
#import "ClientApiInfo.h"
#import "RemoteContext.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"

@implementation NewVersionInfo {
@private
    BOOL _hasNewVersion;
    NSString *_newestVersion;
    NSString *_itemUrl;
    NSString *_httpUrl;
}

@synthesize hasNewVersion = _hasNewVersion;
@synthesize newestVersion = _newestVersion;
@synthesize itemUrl = _itemUrl;
@synthesize httpUrl = _httpUrl;

@end


@implementation FMVersionService {

}
+ (void)getNewVersion:(void (^)(NewVersionInfo *))ret {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"get.new.version"
                                                version:@"1"];
    info.returnClass = [NewVersionInfo class];
    context.info = info;
    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            NewVersionInfo *newVersionInfo = clientApiBaseReturn.data;
            if (ret) {
                ret(newVersionInfo);
            }
        }
    }
    ];
    [context request];
}


@end