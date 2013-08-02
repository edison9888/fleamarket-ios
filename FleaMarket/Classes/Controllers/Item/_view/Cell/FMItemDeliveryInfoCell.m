// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemDeliveryInfoCell.h"
#import "FMDeliveryDO.h"

@implementation FMItemDeliveryInfoCell {
    UILabel *_userLabel;
    UILabel *_addressLabel;
    UIView *_lineView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect userRect = {{10, 10}, FM_SCREEN_WIDTH - 20, 20};
        UILabel *userLabel = [[UILabel alloc] initWithFrame:userRect];
        userLabel.backgroundColor = [UIColor clearColor];
        userLabel.textAlignment = NSTextAlignmentLeft;
        userLabel.font = FMFont(NO, 14.f);
        userLabel.textColor = FMColorWithRed(152, 152, 152);
        [self.contentView addSubview:userLabel];
        _userLabel = userLabel;

        CGRect addressRect = {{10, userRect.origin.y + userRect.size.height}, {FM_SCREEN_WIDTH - 20, 20}};
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:addressRect];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = FMFont(NO, 14.f);
        addressLabel.textColor = FMColorWithRed(152, 152, 152);
        addressLabel.textAlignment = NSTextAlignmentLeft;
        addressLabel.numberOfLines = 0;
        [self.contentView addSubview:addressLabel];
        _addressLabel = addressLabel;

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = FMColorWithRed(231, 230, 226);
        [self.contentView addSubview:lineView];
        _lineView = lineView;
    }

    return self;
}

- (void)setDeliveryDO:(FMDeliveryDO *)deliveryDO {
    _userLabel.text = [NSString stringWithFormat:@"%@ %@", deliveryDO.fullName, deliveryDO.mobile];
    _addressLabel.text = [deliveryDO getFullAddress];

    CGSize addressSize = [FMItemDeliveryInfoCell addressSize:deliveryDO];
    CGRect addressRect = _addressLabel.frame;
    addressRect.size.height = addressSize.height;
    _addressLabel.frame = addressRect;

    _lineView.frame = CGRectMake(0, addressRect.origin.y + addressRect.size.height + 10 - 1, FM_SCREEN_WIDTH, 1);
}

+ (CGSize)addressSize:(FMDeliveryDO *)deliveryDO {
    return [[deliveryDO getFullAddress] sizeWithFont:FMFont(NO, 14.f)
                                 constrainedToSize:CGSizeMake(300, 1000)
                                     lineBreakMode:NSLineBreakByWordWrapping];

}

+ (float)cellHeight:(FMDeliveryDO *)deliveryDO {
    CGSize addressSize = [FMItemDeliveryInfoCell addressSize:deliveryDO];
    return 10 + 20 + addressSize.height + 10;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        _userLabel.textColor = [UIColor whiteColor];
        _addressLabel.textColor = [UIColor whiteColor];
        return;
    }
    _userLabel.textColor = FMColorWithRed(152, 152, 152);
    _addressLabel.textColor = FMColorWithRed(152, 152, 152);
    return;
}


@end