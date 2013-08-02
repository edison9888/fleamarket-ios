//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMItemResellCell.h"
#import "FMImageView.h"
#import "FMStyle.h"
#import "FMTradeDO.h"
#import "UIImage+Helper.h"

#define kTradeCellStartX             10
#define kTradeCellWidth              (FM_SCREEN_WIDTH - 20)
#define kTradeCellHeight             200
#define kTradeCellBaseViewBgHeight   130
#define kTradeCellOperationHeight    (kTradeCellHeight - kTradeCellBaseViewBgHeight)

@implementation FMItemResellCell {
@private
    UIView *_baseViewBg;
    UIView *_operationAreaView;
    UILabel *_orderStatus;

    FMImageView *_headImage;
    UILabel *_itemTitle;
    UILabel *_itemPrice;

    UILabel *_totalPrice;
    UIButton *_resellButton;
    UIButton *_tradeTime;
    UILabel *_resellLabel;
    UIButton *_modifyButton;
    UIButton *_closeTradeButton;
    UIButton *_modifyShipmentButton;

    FMOrderList *_orderList;
}

- (id)initWithStyle:(UITableViewCellStyle)style {
    self = [super initWithStyle:style reuseIdentifier:nil];
    if (self) {
        UIView *groupView = [[UIView alloc] initWithFrame:
                CGRectMake(0, 0, kTradeCellWidth, kTradeCellHeight - 1)];
        groupView.layer.cornerRadius = 8;
        groupView.clipsToBounds = YES;
        [self.contentView addSubview:groupView];

        _baseViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTradeCellWidth, kTradeCellBaseViewBgHeight)];
        _baseViewBg.backgroundColor = [UIColor whiteColor];
        [groupView addSubview:_baseViewBg];

        _operationAreaView = [[UIView alloc] initWithFrame:
                CGRectMake(0, kTradeCellBaseViewBgHeight, kTradeCellWidth, kTradeCellOperationHeight)];
        _operationAreaView.backgroundColor = FMColorWithRed(240, 240, 240);
        [groupView addSubview:_operationAreaView];

        [self initOrderStatus];
        [self initOrderBaseInfo];
        [self initOperationArea];

        UIImageView *groupBottomLine = [[UIImageView alloc] initWithFrame:
                CGRectMake(0, kTradeCellBaseViewBgHeight, kTradeCellWidth, 2)];
        groupBottomLine.image = [UIImage imageNamed:@"item_shadow.png"];
        [groupView addSubview:groupBottomLine];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _baseViewBg = [[UIView alloc] initWithFrame:
                CGRectMake(kTradeCellStartX, kTradeCellStartX, kTradeCellWidth, kTradeCellBaseViewBgHeight)];
        _baseViewBg.backgroundColor = [UIColor whiteColor];
        _baseViewBg.layer.borderWidth = 0.5;
        _baseViewBg.layer.borderColor = FMColorWithRed(216, 214, 198).CGColor;
        [self.contentView addSubview:_baseViewBg];

        _operationAreaView = [[UIView alloc] initWithFrame:
                CGRectMake(kTradeCellStartX, kTradeCellStartX + kTradeCellBaseViewBgHeight, kTradeCellWidth, kTradeCellOperationHeight)];
        _operationAreaView.backgroundColor = FMColorWithRed(240, 240, 240);
        [self.contentView addSubview:_operationAreaView];

        [self initOrderStatus];
        [self initOrderBaseInfo];
        [self initOperationArea];

        UIImageView *groupBottomLine = [[UIImageView alloc] initWithFrame:
                CGRectMake(kTradeCellStartX, kTradeCellStartX + kTradeCellBaseViewBgHeight, kTradeCellWidth, 2)];
        groupBottomLine.image = [UIImage imageNamed:@"item_shadow.png"];
        [self.contentView addSubview:groupBottomLine];
    }
    return self;
}

- (void)initOrderStatus {
    _orderStatus = [[UILabel alloc] initWithFrame:CGRectMake((kTradeCellWidth - 200)/2, kTradeCellStartX, 200, 18)];
    _orderStatus.backgroundColor = FMColorWithRed(231, 231, 231);
    _orderStatus.textColor = FMColorWithRed(172, 172, 172);
    _orderStatus.textAlignment = NSTextAlignmentCenter;
    _orderStatus.font = FMFont(NO, 12);
    CALayer *layer = _orderStatus.layer;
    layer.cornerRadius = 3;
    [_baseViewBg addSubview:_orderStatus];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kTradeCellStartX, 38, 280, 1)];
    line.backgroundColor = FMColorWithRed(234, 234, 234);
    [_baseViewBg addSubview:line];
}

- (void)initOrderBaseInfo {
    _headImage = [[FMImageView alloc] initWithFrame:CGRectMake(kTradeCellStartX, 50, 70, 70)];
    [_baseViewBg addSubview:_headImage];

    _itemTitle = [[UILabel alloc] initWithFrame:CGRectMake(kTradeCellStartX + 70 + 15, 50, 200, 20)];
    _itemTitle.font = [FMFontSize instance].cellLabelSize;
    _itemTitle.textColor = [FMColor instance].cellColor;
    _itemTitle.backgroundColor = [UIColor clearColor];
    _itemTitle.numberOfLines = 1;
    [_baseViewBg addSubview:_itemTitle];

    _itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(kTradeCellStartX + 70 + 15, 50 + 20, 200, 20)];
    _itemPrice.font = [FMFontSize instance].cellLabelSize;
    _itemPrice.textColor = [FMColor instance].priceColor ;
    _itemPrice.backgroundColor = [UIColor clearColor];
    [_baseViewBg addSubview:_itemPrice];
}

- (void)initOperationArea {
    UILabel *priceInfo = [[UILabel alloc] initWithFrame:CGRectMake(kTradeCellStartX, 10, 70, 29)];
    priceInfo.adjustsFontSizeToFitWidth = YES;
    priceInfo.font = FMFont(NO, 12);
    priceInfo.text = @"总计(含运费):";
    priceInfo.textColor = [FMColor instance].cellColor;
    priceInfo.backgroundColor = [UIColor clearColor];
    [_operationAreaView addSubview:priceInfo];

    _totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 150, 29)];
    _totalPrice.adjustsFontSizeToFitWidth = YES;
    _totalPrice.font = FMFont(NO, 13);
    _totalPrice.textColor = [FMColor instance].cellColor;
    _totalPrice.backgroundColor = [UIColor clearColor];
    [_operationAreaView addSubview:_totalPrice];

    _resellLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 10, 120, 29)];
    _resellLabel.backgroundColor = [UIColor clearColor];
    _resellLabel.textAlignment = NSTextAlignmentLeft;
    _resellLabel.font = FMFont(NO, 13.f);
    _resellLabel.textColor = FMColorWithRed(0x66, 0x66, 0x66);
    _resellLabel.hidden = YES;
    [_operationAreaView addSubview:_resellLabel];

    _modifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modifyButton setBackgroundImage:[self greenBtn] forState:UIControlStateNormal];
    _modifyButton.frame = CGRectMake(165, 10, 60, 29);
    [_modifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _modifyButton.titleLabel.font = FMFont(NO, 12.0f);
    [_modifyButton addTarget:self
                      action:@selector(modifyPriceAction)
            forControlEvents:UIControlEventTouchUpInside];
    [_modifyButton setTitle:@"修改价格" forState:UIControlStateNormal];
    _modifyButton.hidden = YES;
    [_operationAreaView addSubview:_modifyButton];

    _closeTradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeTradeButton setBackgroundImage:[self gayBtn] forState:UIControlStateNormal];
    _closeTradeButton.frame = CGRectMake(230, 10, 60, 29);
    [_closeTradeButton setTitleColor:FMColorWithRed(74, 76, 77) forState:UIControlStateNormal];
    _closeTradeButton.titleLabel.font = FMFont(NO, 12.0f);
    [_closeTradeButton addTarget:self
                          action:@selector(closeTradeAction)
                forControlEvents:UIControlEventTouchUpInside];
    [_closeTradeButton setTitle:@"关闭交易" forState:UIControlStateNormal];
    _closeTradeButton.hidden = YES;
    [_operationAreaView addSubview:_closeTradeButton];

    _modifyShipmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modifyShipmentButton setBackgroundImage:[self greenBtn] forState:UIControlStateNormal];
    _modifyShipmentButton.frame = CGRectMake(220, 10, 60, 29);
    [_modifyShipmentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _modifyShipmentButton.titleLabel.font = FMFont(NO, 12.0f);
    [_modifyShipmentButton addTarget:self
                              action:@selector(modifyShipmentAction)
                    forControlEvents:UIControlEventTouchUpInside];
    [_modifyShipmentButton setTitle:@"修改物流" forState:UIControlStateNormal];
    _modifyShipmentButton.hidden = YES;
    [_operationAreaView addSubview:_modifyShipmentButton];

    _resellButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resellButton setBackgroundImage:[self greenBtn] forState:UIControlStateNormal];
    _resellButton.frame = CGRectMake(165, 10, 60, 29);
    _resellButton.backgroundColor = [UIColor clearColor];
    _resellButton.titleLabel.font = FMFont(NO, 12.0f);
    [_resellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_resellButton addTarget:self action:@selector(resellButton:) forControlEvents:UIControlEventTouchUpInside];
    [_operationAreaView addSubview:_resellButton];

    _tradeTime = [[UIButton alloc] initWithFrame:CGRectMake(kTradeCellStartX, 45, 70, 20)];
    _tradeTime.backgroundColor = [UIColor clearColor];
    [_tradeTime setTitleColor:FMColorWithRed(99, 99, 99) forState:UIControlStateNormal];
    _tradeTime.titleLabel.font = FMFont(NO, 10);
    _tradeTime.enabled = NO;
    [_tradeTime setImage:[UIImage imageWithFileName:@"post_time_icon.png"] forState:UIControlStateNormal];
    _tradeTime.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [_operationAreaView addSubview:_tradeTime];
}

- (void)setData:(FMOrderList *)orderList type:(FMItemResellCellType)type {
    _orderList = orderList;
    if (orderList.orders.order.count == 0) {
        return;
    }
    _orderStatus.text = [NSString stringWithFormat:@"订单状态:%@", [orderList getStatus]];
    FMOrderDetail *orderDetail = [orderList.orders.order objectAtIndex:0];
    if (orderDetail.pic_path) {
        [_headImage setWebPImageWithURL:orderDetail.pic_path
                         imageScaleType:FMImageScale160x160
                       placeholderImage:FMPlaceholderImage];
    } else {
        _headImage.image = [UIImage imageWithFileName:@"no_image80.png"];
    }

    _itemTitle.text = orderDetail.title;
    CGSize size = [_itemTitle.text sizeWithFont:_itemTitle.font
                              constrainedToSize:CGSizeMake(200, 40)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    _itemTitle.frame = CGRectMake(kTradeCellStartX + 70 + 15, 50, size.width, size.height);

    _itemPrice.text = [NSString stringWithFormat:@"￥%@", orderDetail.price];
    _itemPrice.frame = CGRectMake(kTradeCellStartX + 70 + 15, 50 + size.height, 200, 20);

    _totalPrice.text = [NSString stringWithFormat:@"￥%@", orderList.payment];

    [self setLeftButton:orderList type:type];

    NSString *timeStr = [[orderList.modified componentsSeparatedByString:@" "] objectAtIndex:0];
    [_tradeTime setTitle:timeStr forState:UIControlStateNormal];
}

- (void)setLeftButton:(FMOrderList *)orderList type:(FMItemResellCellType)type {
    FMOrderDetail *orderDetail = [orderList.orders.order objectAtIndex:0];
    [_resellButton setTitle:@"我要发货" forState:UIControlStateNormal];
    if ([orderDetail isDummyShipment]) {
        _resellLabel.text = @"已发货(无需物流)";
    } else {
        _resellLabel.text = @"已发货";
    }
    if (type == FMItemResellCellSoldTrade && [orderList.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"]) {
        _resellButton.hidden = YES;
        _resellLabel.hidden = NO;
        if ([orderDetail isDummyShipment]) {
            _modifyShipmentButton.hidden = YES;
        } else {
            _modifyShipmentButton.hidden = NO;
        }
        _closeTradeButton.hidden = YES;
        _modifyButton.hidden = YES;
    } else if (type == FMItemResellCellSoldTrade && [orderList.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"]) {
        _resellButton.hidden = NO;
        _resellButton.frame = CGRectMake(230, 10, 60, 29);
        _resellLabel.hidden = YES;
        _modifyShipmentButton.hidden = YES;
        _closeTradeButton.hidden = YES;
        _modifyButton.hidden = YES;
    } else if (type == FMItemResellCellSoldTrade && [orderList.status isEqualToString:@"WAIT_BUYER_PAY"]) {
        _resellButton.hidden = YES;
        _resellLabel.hidden = YES;
        _modifyShipmentButton.hidden = YES;
        _closeTradeButton.hidden = NO;
        _modifyButton.hidden = NO;
    } else {
        _resellButton.hidden = YES;
        _resellLabel.hidden = YES;
        _modifyShipmentButton.hidden = YES;
        _closeTradeButton.hidden = YES;
        _modifyButton.hidden = YES;
    }
}

- (UIImage *)greenBtn {
    return [[UIImage imageWithFileName:@"btn_green.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

- (UIImage *)gayBtn {
    return [[UIImage imageNamed:@"btn_gay.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

- (void)resellButton:(id)sender {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushShipmentsViewController:orderList:), _orderList);
}

- (void)modifyPriceAction {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushModifyPriceViewController:orderList:), _orderList);
}

- (void)closeTradeAction {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushCloseTradeViewController:orderList:), _orderList);
}

- (void)modifyShipmentAction {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushShipmentsViewController:orderList:), _orderList);
}

@end