// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMShipmentsItemInfoCell.h"

@implementation FMShipmentsItemInfoCell {
    UILabel *_leftLabel;
    UILabel *_rightLabel;
}

@synthesize rightLabel = _rightLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect leftRect = {{10,12},{90,20}};
        _leftLabel = [[UILabel alloc] initWithFrame:leftRect];
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.font = FMFont(YES, 15.f);
        _leftLabel.textColor = FMColorWithRed(0x66, 0x66, 0X66);
        [self.contentView addSubview:_leftLabel];

        CGRect rightRect = {{90,12},{200,20}};
        _rightLabel = [[UILabel alloc] initWithFrame:rightRect];
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.font = FMFont(YES, 15.f);
        _rightLabel.textColor = FMColorWithRed(0x22, 0x22, 0X22);
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_rightLabel];
    }

    return self;
}

- (void)setLeft:(NSString *)leftText right:(NSString *)rightText {
    _leftLabel.text = leftText;
    _rightLabel.text = rightText;
}

@end