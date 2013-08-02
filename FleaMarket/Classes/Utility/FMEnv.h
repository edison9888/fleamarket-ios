//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午8:02.
//


#import <Foundation/Foundation.h>

extern inline NSString *get_app_version();
//环境变量

#define DEFAULT_APP_VERSION                    @"4.0.0"

#define SYSTEM_REQUEST_TIMEOUT                 30

#define kWBSDKAppKey                         @"1592822997"
#define kWBSDKAppSecret                      @"4aab976234ebf038423d35eaefb8ac8c"

// API Configure
// test
#ifdef DAILY_SERVER_TEST
//#define APP_KEY                                  @"4272"
#define APP_KEY                                  @"541941"
//#define APP_SECRET_KEY                           @"0ebbcccfee18d7ad1aebc5b135ffa906"
#define APP_SECRET_KEY                           @"9949851826937578962680d72dc23ccc"

#define API_ERSHOU_SECRET_KEY                    @"taobao%)!@@^TAOBAO"
#define API_ERSHOU_HOST                          @"http://api.ershou.daily.taobao.net/api"

#define MTOP_API_HOST                            @"http://api.waptest.taobao.com/rest/api3.do"
#define MTOP_API_HOST2                           @"http://api.waptest.taobao.com/rest/api2.do"
#define kTaoBaoTopHost                           @"http://api.daily.taobao.net/router/rest"
//@"waptest.taobao.com"
#define URL_TAOBAO_DOMAIN                        @"10.235.144.38"
#define kErshouItemHost                          @"http://ershou.daily.taobao.net/item.htm?id=%@"
#define kApiHeadPortrait                         @"http://wsapi.jianghu.daily.taobao.net/avatar/getAvatar.do?userId=%@&width=110&height=110&type=sns"
#define TB_API_ENV                               2
#define TOP_ENV                                  TBRO_ENV_Daily

#define TAO_PHOTO_REFER                          @"http://ershou.daily.taobao.net"
#define RECYCLE_WEB_URL                          @"http://api.ershou.daily.taobao.net/api?api=mobile.recover&v=1"

#define TBSDKNETWORKENV                          TBSDKEnvironmentDaily
#define kItemDefaultCategoryId                   @"50023148"

// prepare
#elif PREPARE_SERVER_TEST
//@"12497914"
#define APP_KEY                                  @"12431167"
//@"4b0f28396e072d67fae169684613bcd1"
#define APP_SECRET_KEY                           @"755eca2ad1d054de1122c63a9fed396b"


#define API_ERSHOU_SECRET_KEY                    @"taobao%)!@@^TAOBAO"
#define API_ERSHOU_HOST                          @"http://110.75.40.144/api"
#define MTOP_API_HOST                            @"http://api.wapa.taobao.com/rest/api3.do"
#define MTOP_API_HOST2                           @"http://api.wapa.taobao.com/rest/api2.do"
#define kTaoBaoTopHost                           @"http://gw.api.taobao.com/router/rest"

#define URL_TAOBAO_DOMAIN                        @"m.taobao.com"
#define kErshouItemHost                          @"http://ershou.taobao.com/item.htm?id=%@"
#define kApiHeadPortrait                         @"http://wwc.taobaocdn.com/avatar/getAvatar.do?userId=%@&width=110&height=110&type=sns"
#define TB_API_ENV                               1
#define TOP_ENV                                  TBRO_ENV_PreRelease

#define TAO_PHOTO_REFER                          @"http://ershou.taobao.com"
#define RECYCLE_WEB_URL                          @"http://110.75.40.144/api?api=mobile.recover&v=1"

#define TBSDKNETWORKENV                          TBSDKEnvironmentDebug
#define kItemDefaultCategoryId                   @"50023914"

// release
#else
#define APP_KEY                                  @"12431167"
#define APP_SECRET_KEY                           @"755eca2ad1d054de1122c63a9fed396b"

#define API_ERSHOU_SECRET_KEY                    @"taobao%)!@@^TAOBAO"
#define API_ERSHOU_HOST                          @"http://api.ershou.taobao.com/api"

#define MTOP_API_HOST                            @"http://api.m.taobao.com/rest/api3.do"
#define MTOP_API_HOST2                           @"http://api.m.taobao.com/rest/api2.do"
#define kTaoBaoTopHost                           @"http://gw.api.taobao.com/router/rest"

#define URL_TAOBAO_DOMAIN                        @"m.taobao.com"
#define kErshouItemHost                          @"http://ershou.taobao.com/item.htm?id=%@"
#define kApiHeadPortrait                         @"http://wwc.taobaocdn.com/avatar/getAvatar.do?userId=%@&width=110&height=110&type=sns"
#define TB_API_ENV                               0
#define TOP_ENV                                  TBRO_ENV_Release

#define TAO_PHOTO_REFER                          @"http://ershou.taobao.com"
#define RECYCLE_WEB_URL                          @"http://api.ershou.taobao.com/api?api=mobile.recover&v=1"

#define TBSDKNETWORKENV                          TBSDKEnvironmentRelease
#define kItemDefaultCategoryId                   @"50023914"

#endif


#define APP_STORE_DOWNLOAD_URL                   @"http://tsu.taobao.com/r/q2Vav"
#define FM_APP_VERSION                           (get_app_version())
#define TTID_GENERATOR(CHANNEL)                  ([NSString stringWithFormat:@"%@@fleamarket_iphone_%@",(CHANNEL),FM_APP_VERSION])

// 渠道推广ID
#ifdef DISTRIBUTE_WEIPHONE
#define TA_CHANNEL                               @"WeiPhone"
#elif DISTRIBUTE_91
#define TA_CHANNEL                               @"91Assist"
#else
#define TA_CHANNEL                               @"AppStore"
#endif


#define kTTIDForAppStore                         TTID_GENERATOR(@"201200")
#define kTTIDForWeiPhone                         TTID_GENERATOR(@"225200")
#define kTTIDFor91Assist                         TTID_GENERATOR(@"600438")


#ifdef DISTRIBUTE_WEIPHONE
#define kCurrentTTID                             kTTIDForWeiPhone
#elif DISTRIBUTE_91
#define kCurrentTTID                             kTTIDFor91Assist
#else
#define kCurrentTTID                             kTTIDForAppStore
#endif

#define CONSTANT_CACHE                           @"constant_cache_4.x"

#define kApiErShouVersion                        @"1"

#define TBSinaAppKey                             @"3452444607"
#define TBSinaAppSecret                          @"9fa3e3f0cd696a4b7fc6a58bba005ca2"
#define TBSinaAppRedirectURI                     @"http://open.weibo.com/apps/3452444607/info/advanced"

#define TBDoubanAppKey                           @"0c3213ecf48fd89624963bc6ddaf89c2"
#define TBDoubanAppSecret                        @"edf944bbdf53d5e1"
#define TBDoubanAppRedirectURI                   @"http://t.taobao.com/cooperate/connect/douban_callback.htm"


#define TBWeChatAppID                            @"wxf79df423c450bcaf"

#define kSuggestionMail                          @"taobao-fleamarket-client@list.alibaba-inc.com"
