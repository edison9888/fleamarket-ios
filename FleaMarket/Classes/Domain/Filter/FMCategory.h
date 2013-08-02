//
// Created by yuanxiao on 12-10-9.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBIUConvertDefine.h"
#import "EXTAnnotation.h"

@interface FMCategoryList : NSObject {
    NSArray *_items;
}
@annotate(FMCategoryList, TBIU_ANN_TYPE : @"FMCategory")
@property(nonatomic, strong) NSArray *items;

@end

@interface FMCategory : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *id;
@property(nonatomic, assign) BOOL leaf;
@end