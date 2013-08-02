// 
// Created by henson on 6/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import "FMItemBuyViewController.h"
#import "FMItemBuyInfoView.h"
#import "FMSegmentedControl.h"
#import "FMItemService.h"
#import "FMDeliveryDO.h"
#import "FMDeliveryAddressViewController.h"
#import "FMUser.h"
#import "FMApplication.h"
#import "FMTradesService.h"
#import "FMWebviewController.h"
#import "FMBaseTableViewCell.h"
#import "FMUserTrack.h"

@interface FMItemBuyViewController ()

@property(nonatomic, strong) FMItemDO *itemDO;

@end

@implementation FMItemBuyViewController {
    UITableView *_tableView;
    UILabel *_addressLabel;
    UITextField *_userTextField;
    UITextField *_phoneTextField;
    FMItemTradeType _tradeType;
    UIButton *_hideKeyboardButton;

    FMDeliveryDO *_deliveryDO;
    NSString *_tradePayURL;

@private
    FMItemDO *_itemDO;

    BOOL _deliverySuccess;
}

@synthesize itemDO = _itemDO;

- (id)initWithItemDO:(FMItemDO *)itemDO {
    self = [super init];
    if (self) {
        self.itemDO = itemDO;
        _tradeType = itemDO.offline == FMItemTradeTypeAnyway ? FMItemTradeTypeOnline : itemDO.offline;
        _deliveryDO = nil;
    }

    return self;
}

+ (id)controllerWithItemDO:(FMItemDO *)itemDO {
    return [[self alloc] initWithItemDO:itemDO];
}

- (void)initNavigationBar {
    [self setTitle:@"购买宝贝"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight - kStatusBarHeight}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    tableView.backgroundView = nil;
    tableView.backgroundColor = FMColorWithRed(237, 235, 223);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = [self tableHeaderView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
    _tableView = tableView;

    _addressLabel = [self getAddressLabel];
    _userTextField = [self userTextField];
    _phoneTextField = [self phoneTextField];

    [self initHideKeyboardButton];
}

- (UIView *)tableHeaderView {
    float height = [self isShowControl] ? 145 : 90;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, height)];

    CGRect infoRect = {{0, 0}, {FM_SCREEN_WIDTH, 90}};
    FMItemBuyInfoView *buyInfoView = [[FMItemBuyInfoView alloc] initWithFrame:infoRect];
    buyInfoView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:buyInfoView];
    [buyInfoView setItemDO:_itemDO];

    __weak FMItemBuyViewController *selfWeak = self;
    if ([self isShowControl]) {
        FMSegmentedControl *tradeTypeControl = [self tradeTypeControl];
        [tradeTypeControl setSegmentChangedAction:^(FMSegmentedControlItem *item) {
            [selfWeak segmentChanged:item];
        }];
        [headerView addSubview:tradeTypeControl];
    }

    return headerView;
}

- (void)initHideKeyboardButton {
    if (_hideKeyboardButton) {
        [_hideKeyboardButton removeFromSuperview];
        _hideKeyboardButton = nil;
    }

    CGRect keyboardRect = {{FM_SCREEN_WIDTH - 52, FM_SCREEN_HEIGHT + 31}, {42, 31}};
    _hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hideKeyboardButton.frame = keyboardRect;
    [_hideKeyboardButton addTarget:self
                            action:@selector(hideKeyboard)
                  forControlEvents:UIControlEventTouchUpInside];
    [_hideKeyboardButton setBackgroundImage:[UIImage imageNamed:@"keyboard_hide_icon.png"]
                                   forState:UIControlStateNormal];
    [self.view addSubview:_hideKeyboardButton];
}

- (void)hideKeyboardButton:(NSTimeInterval)animationDuration {
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 52, FM_SCREEN_HEIGHT + 31,
                                 42, 31
                         );
                     }
                     completion:^(BOOL finished) {
                         _hideKeyboardButton.hidden = YES;
                     }];
}

- (void)showKeyboardButton:(NSTimeInterval)animationDuration
                  keyboard:(CGRect)keyboardBounds {
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _hideKeyboardButton.hidden = NO;
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 52,
                                 self.view.frame.size.height - keyboardBounds.size.height - 31,
                                 42, 31
                         );
                     }
                     completion:nil];
}

- (void)hideKeyboard {
    [FMCommon hideKeyboard];
}

- (void)segmentChanged:(FMSegmentedControlItem *)item {
    _tradeType = item.tag == 0 ? FMItemTradeTypeOnline : FMItemTradeTypeF2F;
    [_tableView reloadData];
}

- (FMSegmentedControl *)tradeTypeControl {
    FMSegmentedControlItem *online = [[FMSegmentedControlItem alloc] initWithTitle:@"在线交易"];
    online.tag = 0;
    FMSegmentedControlItem *face = [[FMSegmentedControlItem alloc] initWithTitle:@"见面交易"];
    face.tag = 1;

    CGRect segmentRect = {{10, 100}, {300, 44}};
    FMSegmentedControl *control = [[FMSegmentedControl alloc] initWithFrame:segmentRect];
    control.backgroundColor = [UIColor clearColor];
    [control setSegmentedItems:@[online, face]];
    [control setSelectedIndex:0];
    return control;
}

- (UILabel *)getAddressLabel {
    CGRect addressRect = {{95, 1.5}, {180, 55.5}};
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:addressRect];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.textAlignment = NSTextAlignmentRight;
    addressLabel.numberOfLines = 0;
    addressLabel.font = FMFont(NO, 12.f);
    addressLabel.textColor = FMColorWithRed(163, 163, 163);
    addressLabel.text = @"正在获取收货地址..";
    return addressLabel;
}

- (UILabel *)getShipmentLabel {
    CGRect shipmentRect = {{95, 1.5}, {190, 55.5}};
    UILabel *shipmentLabel = [[UILabel alloc] initWithFrame:shipmentRect];
    shipmentLabel.backgroundColor = [UIColor clearColor];
    shipmentLabel.contentMode = UIViewContentModeCenter;
    shipmentLabel.textAlignment = NSTextAlignmentRight;
    shipmentLabel.numberOfLines = 0;
    shipmentLabel.font = FMFont(YES, 15.f);
    shipmentLabel.textColor = FMColorWithRed(221, 79, 109);
    shipmentLabel.text = [NSString stringWithFormat:@"¥ %@ 快递", _itemDO.postPrice];
    return shipmentLabel;
}

- (UILabel *)getTotalPriceLabel {
    CGRect priceRect = {{95, 1.5}, {190, 55.5}};
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceRect];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textAlignment = NSTextAlignmentRight;
    priceLabel.numberOfLines = 0;
    priceLabel.font = FMFont(YES, 15.f);
    priceLabel.textColor = FMColorWithRed(221, 79, 109);
    priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",
                                                 [_itemDO.postPrice doubleValue] + [_itemDO.price doubleValue]];
    return priceLabel;
}

- (UITextField *)userTextField {
    UITextField *userTextField = [[UITextField alloc] initWithFrame:CGRectMake(90.f, 12.5f, 200.0f, 36.0f)];
    userTextField.placeholder = @"请输入收货人姓名";
    userTextField.textAlignment = (NSTextAlignment) UITextAlignmentRight;
    userTextField.textColor = FMColorWithRed(0x66, 0x66, 0x66);
    userTextField.font = FMFont(NO, 15.0f);
    userTextField.returnKeyType = UIReturnKeyNext;
    userTextField.backgroundColor = [UIColor clearColor];
    userTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userTextField.delegate = self;
    return userTextField;
}

- (UITextField *)phoneTextField {
    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(90.f, 12.5f, 200.0f, 36.0f)];
    phoneTextField.placeholder = @"请输入联系人手机";
    phoneTextField.textAlignment = (NSTextAlignment) UITextAlignmentRight;
    phoneTextField.textColor = FMColorWithRed(0x66, 0x66, 0x66);
    phoneTextField.font = FMFont(NO, 15.0f);
    phoneTextField.returnKeyType = UIReturnKeyDone;
    phoneTextField.backgroundColor = [UIColor clearColor];
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    phoneTextField.delegate = self;
    return phoneTextField;
}

- (UILabel *)getPriceLabel {
    CGRect priceRect = {{95, 1.5}, {190, 55.5}};
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceRect];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textAlignment = NSTextAlignmentRight;
    priceLabel.numberOfLines = 0;
    priceLabel.font = FMFont(YES, 15.f);
    priceLabel.textColor = FMColorWithRed(221, 79, 109);
    priceLabel.text = [NSString stringWithFormat:@"¥ %.2f", [_itemDO.price doubleValue]];
    return priceLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestDeliveryAddress];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)confirmAction {
    [FMCommon hideKeyboard];
    NSString *sellerId = [NSString stringWithFormat:@"%@", _itemDO.userId];

    FMUser *user = [FMApplication instance].loginUser;
    if ([sellerId isEqualToString:user.id]) {
        [UIAlertView showAlertViewWithTitle:@""
                                    message:@"亲，您不能购买自己的宝贝哦!"
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil
                                    handler:nil];
        return;
    }

    if (_tradeType == FMItemTradeTypeOnline) {
        if (!_deliveryDO) {
            [UIAlertView showAlertViewWithTitle:@""
                                        message:@"亲，收货地址为空，不能下单!"
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil
                                        handler:nil];
            return;
        }
        [self requestCreateTrade:_deliveryDO
                       buyerName:nil
                      buyerPhone:nil];
    } else {
        if (_userTextField.text == nil || _userTextField.text.length <= 0) {
            [UIAlertView showAlertViewWithTitle:@""
                                        message:@"亲，请输入收货人姓名!"
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil
                                        handler:nil];
            return;
        }
        if (_phoneTextField.text == nil || _phoneTextField.text.length <= 0) {
            [UIAlertView showAlertViewWithTitle:@""
                                        message:@"亲，请输入联系人手机!"
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil
                                        handler:nil];
            return;
        }
        [self requestCreateTrade:nil
                       buyerName:_userTextField.text
                      buyerPhone:_phoneTextField.text];
    }
}

- (void)requestCreateTrade:(FMDeliveryDO *)deliveryDO
                 buyerName:(NSString *)buyerName
                buyerPhone:(NSString *)buyerPhone {
    [FMTradesService createTrade:_itemDO.id
                       deliverId:deliveryDO.deliverId
                       buyerName:buyerName
                      buyerPhone:buyerPhone
                          result:^(BOOL isSuccess, NSString *alipayNO, NSString *errMsg) {
                              if (isSuccess) {
                                  _tradePayURL = alipayNO;
                                  [self sendNotificationForSEL:@selector($$getIdleUserInfo:)];
                                  [UIAlertView showAlertViewWithTitle:nil
                                                              message:@"下单成功，请前往支付宝付款"
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil
                                                              handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                  [self payment];
                                                              }];
                                  return;
                              }

                              if (errMsg) {
                                  [FMCommon alert:@"" message:errMsg];
                                  return;
                              }
                          }];
}

#pragma mark - UIAlertView delegate
- (void)payment {
    [FMUserTrack ctrlClicked:@"FM_ORDER_SUCCESS" onPage:self];
    if (self.isFromTheme) {
        [FMUserTrack ctrlClicked:@"FM_ORDER_SUCCESS_FROM_THEME" onPage:self];
    }

    FMUser *user = [FMApplication instance].loginUser;
    NSString *urlString=[NSString stringWithFormat:@"http://mali.alipay.com/w/trade_pay.do?alipay_trade_no=%@&s_id=%@&refer=tbc&tclient=iphone&taobaoclient=fs", _tradePayURL,user.sid];
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.url = urlString;
    webView.title = @"宝贝付款";
    webView.webViewType = FMWebViewTypeRequest;
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)autoMoveKeyboard:(float)h {
    if (_tradeType == FMItemTradeTypeF2F) {
        if (h > 0) {
            [_tableView setContentOffset:CGPointMake(0, 90) animated:YES];
            return;
        }
    }

    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    return;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [self autoMoveKeyboard:keyboardRect.size.height];
    [self showKeyboardButton:animationDuration keyboard:keyboardRect];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self autoMoveKeyboard:0];
    [self hideKeyboardButton:animationDuration];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)requestDeliveryAddress {
    [FMItemService getDeliveryInfoList:^(BOOL isSuccess, FMDeliveryDOList *deliveryDOList, NSString *errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                FMDeliveryDO *deliveryDO = [deliveryDOList.addressList objectAtIndex:0];
                [self updateAddress:deliveryDO];
                [_tableView reloadData];
                _deliveryDO = deliveryDO;
                return;
            }
        });
    }];
}

- (void)updateAddress:(FMDeliveryDO *)deliveryDO {
    if (deliveryDO) {
        NSString *info = [NSString stringWithFormat:@"%@ %@", deliveryDO.fullName, deliveryDO.mobile];
        _addressLabel.text = [NSString stringWithFormat:@"%@\n%@", info, [deliveryDO getFullAddress]];
        _deliverySuccess = YES;
    } else {
        _addressLabel.text = @"获取收货地址失败";
        _deliverySuccess = NO;
    }
}
#pragma mark - UITextField delegate.
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    if (aTextField == _userTextField) {
        [_phoneTextField becomeFirstResponder];
    } else {
        [aTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string; {
    if ([string isEqualToString:@"\n"])
        return YES;

    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([_phoneTextField isFirstResponder] && [toBeString length] > 11) {
        textField.text = [toBeString substringToIndex:11];
        [UIAlertView showAlertViewWithTitle:@""
                                    message:@"手机号码最多11位数字"
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil
                                    handler:nil];
        return NO;
    } else if ([_userTextField isFirstResponder] && [toBeString length] > 30) {
        textField.text = [toBeString substringToIndex:30];
        [UIAlertView showAlertViewWithTitle:@""
                                    message:@"收货人最多输入30个字"
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil
                                    handler:nil];
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMBaseTableViewCell *cell = [[FMBaseTableViewCell alloc] init];
    NSUInteger row = (NSUInteger) indexPath.row;

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.isCanSelect = NO;

    if (indexPath.section == 1) {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        UIButton *logoutButton = [self getConfirmButton];
        [cell.contentView addSubview:logoutButton];
        return cell;
    }

    if (_tradeType == FMItemTradeTypeOnline) {
        if (row == 0) {
            cell.textLabel.text = @"收货地址";
            cell.accessoryType = _deliverySuccess ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            [cell.contentView addSubview:_addressLabel];
            cell.isCanSelect = _deliverySuccess;
        } else if (row == 1) {
            cell.textLabel.text = @"运送方式";
            [cell.contentView addSubview:[self getShipmentLabel]];
        } else {
            cell.textLabel.text = @"实付金额";
            [cell.contentView addSubview:[self getTotalPriceLabel]];
        }
    } else if (_tradeType == FMItemTradeTypeF2F) {
        if (row == 0) {
            cell.textLabel.text = @"收货人";
            [cell.contentView addSubview:_userTextField];
        } else if (row == 1) {
            cell.textLabel.text = @"联系手机";
            [cell.contentView addSubview:_phoneTextField];
        } else {
            cell.textLabel.text = @"实付金额";
            [cell.contentView addSubview:[self getPriceLabel]];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) indexPath.row;
    __weak FMItemBuyViewController *selfWeak = self;
    if (_deliverySuccess && _tradeType == FMItemTradeTypeOnline && row == 0) {
        FMDeliveryAddressViewController *deliveryAddressViewController = [[FMDeliveryAddressViewController alloc] init];
        [deliveryAddressViewController setSelectAction:^(FMDeliveryDO *deliveryDO) {
            [selfWeak updateAddress:deliveryDO];
            _deliveryDO = nil;
            _deliveryDO = deliveryDO;
        }];
        [self.navigationController pushViewController:deliveryAddressViewController animated:YES];
    }
}

- (BOOL)isShowControl {
    return _itemDO.offline == FMItemTradeTypeAnyway ? YES : NO;
}

- (UIButton *)getConfirmButton {
    CGRect rect = CGRectMake(0, 0, 300, 44);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FMFont(NO, 18.f);
    [button setBackgroundImage:[self cellButtonBgImage] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImage *)cellButtonBgImage {
    return [[UIImage imageNamed:@"setting_cell_btn_bg.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

@end