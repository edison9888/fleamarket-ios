//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 下午3:58.
//


#import <Foundation/Foundation.h>
#import "Verifiable.h"
#import "TBROCachedInfo.h"


@interface TopInfo : TBROCachedInfo <Verifiable, TBROHasHandler>
@property(copy, nonatomic) NSString *method;
@property(readonly, nonatomic) NSString *fields;
@property(copy, nonatomic) NSString *version;
@property(copy, nonatomic) NSString *topSession;
@property(nonatomic) Class returnClass;

- (id)initWithMethod:(NSString *)method version:(NSString *)version;

+ (id)objectWithMethod:(NSString *)method version:(NSString *)version;


- (void)addField:(NSString *)field;

- (void)addFields:(NSString *)fields;

- (void)addFieldArray:(NSArray *)fields;
@end