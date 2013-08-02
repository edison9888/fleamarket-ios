//
// Created by yuanxiao on 12-10-9.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMCategory.h"

@implementation FMCategoryList

@synthesize items = _items;

@end

@implementation FMCategory {
@private
    BOOL _leaf;
    NSString *_name;
    NSString *_id;
}


@synthesize id = _id;
@synthesize name = _name;
@synthesize leaf = _leaf;


@end