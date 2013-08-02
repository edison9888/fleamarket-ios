//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMBaseTableViewCell.h"


@implementation FMBaseTableViewCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isCanSelect = YES;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.isCanSelect = YES;
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted == YES && self.isCanSelect) {
        self.backgroundColor = FMColorWithRGB0X(0xe9e9e9);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end