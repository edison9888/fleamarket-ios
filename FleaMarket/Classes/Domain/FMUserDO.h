//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-27 上午10:16.
//


#import <Foundation/Foundation.h>


@interface FMUserDO : NSObject


@property(nonatomic, assign) long userId;
@property(nonatomic, copy) NSString *userNick;
@property(nonatomic, copy) NSString *idleSellingNum;
@property(nonatomic, copy) NSString *idleBuyNum;
@property(nonatomic, copy) NSString *idleSoldNum;
@property(nonatomic, copy) NSNumber *idleFavNum;
@end