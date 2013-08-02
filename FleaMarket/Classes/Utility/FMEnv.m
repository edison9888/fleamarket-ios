//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午8:02.
//


static NSString *_FM_APP_VERSION = nil;

inline NSString *get_app_version() {
    if (_FM_APP_VERSION == nil) {
        _FM_APP_VERSION = ([[[NSBundle mainBundle] infoDictionary] objectForKey:
                (NSString *) kCFBundleVersionKey] ? : DEFAULT_APP_VERSION);
    }
    return _FM_APP_VERSION;
}
