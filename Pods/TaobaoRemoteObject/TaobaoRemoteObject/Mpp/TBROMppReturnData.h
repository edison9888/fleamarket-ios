//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-11 下午5:04.
//


#import <Foundation/Foundation.h>

typedef enum {
    TBRO_MPP_TYPE_QUIT = 0,  //被强制退出 参数有问题
    TBRO_MPP_TYPE_TIMEOUT,  //超时
    TBRO_MPP_TYPE_CONTENT,  //有内容(正确返回)
    TBRO_MPP_TYPE_CLOSE    //相同的dt 建立了连接
} TBROMppType;

@interface TBROMppReturnContent : NSObject
@property(nonatomic, assign) int t1;
@property(nonatomic, assign) int t2;
@property(nonatomic, assign) long long v;
@property(nonatomic, assign) long long o;
@property(nonatomic, strong) NSString *i;
@property(nonatomic, strong) id content;

- (id)getContentByClass:(Class)clazz;
@end

@interface TBROMppReturnData : NSObject

@property(nonatomic, assign) TBROMppType type;
@property(nonatomic, retain) NSArray *st$TBROMppReturnContent;
@end