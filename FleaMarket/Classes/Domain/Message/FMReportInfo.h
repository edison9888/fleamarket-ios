//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-25 上午11:17.
//


#import <Foundation/Foundation.h>


@interface FMReportInfo : NSObject
@property(nonatomic, copy) NSString *reporterId;  //对方id
@property(nonatomic, copy) NSString *reporterNick;    //对方昵称
@property(nonatomic, copy) NSString *reporterName;   //对方名字
@end