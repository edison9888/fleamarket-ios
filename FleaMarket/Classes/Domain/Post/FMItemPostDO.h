//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-6 上午10:48.
//


#import <Foundation/Foundation.h>


@interface FMItemPostDO : NSObject
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *area;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *prov;
@property(nonatomic, copy) NSString *gps;
@property(nonatomic, copy) NSString *divisionId;
@property(nonatomic, copy) NSString *offline;
@property(nonatomic, copy) NSString *stuffStatus;
@property(nonatomic, copy) NSString *categoryId;
@property(nonatomic, copy) NSString *contacts;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *originalPrice;
@property(nonatomic, copy) NSString *phone;
@property(nonatomic, copy) NSString *postPrice;
@property(nonatomic, copy) NSString *reservePrice;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) BOOL resell;
@property(nonatomic, assign) long long orderId;
@property(nonatomic, assign) BOOL archive;
@property(nonatomic, copy) NSString *voiceUrl;
@property(nonatomic, assign) NSUInteger voiceTime;

@property(nonatomic, readonly) NSMutableArray *mainPic;
@property(nonatomic, readonly) NSMutableArray *otherPics;
@end