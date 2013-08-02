// 
// Created by henson on 4/23/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#define MAX_SHIP_PRICE       (999.99)
#define MAX_PRICE            (99999999.99)

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "FMModifyPriceViewController.h"
#import "FMItemResellCell.h"
#import "FMShipmentsItemInfoCell.h"
#import "FMTradesService.h"
#import "NSString+Helper.h"
#import "FMCommon.h"
#import "FMMySoldTradeViewController.h"
#import "FMCustomStatusBar.h"
#import "FMTradeDO.h"
#import "FMStyle.h"

@implementation FMModifyPriceViewController {
    UITableView *_modifyTableView;
    UITableView *_orderDetailTableView;
    NSMutableDictionary *_orderInfo;
    UIButton *_hideKeyboardButton;

@private
    FMOrderList *_orderList;
}

@synthesize orderList = _orderList;

- (id)init {
    self = [super init];
    if (self) {
        _orderInfo = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"修改价格"];
    self.leftBarButton.hidden = NO;
    [self setRightButtonTitle:@"确定"];
}

- (void)rightAction:(id)sender {
    [self hideKeyboard];

    UITextField *paymentTextField = [self modifyPaymentTextField];
    UITextField *postFeeTextField = [self modifyPostFeeTextField];
    if ([paymentTextField.text isBlank] || [[self formatPrice:paymentTextField.text] doubleValue] == 0.f) {
        [FMCommon alert:@"" message:@"亲，请输入您要修改的价格"];
        return;
    }

    NSString *payment = [self formatPrice:paymentTextField.text];
    if ([payment doubleValue] > MAX_PRICE) {
        [FMCommon alert:@"" message:@"亲，宝贝价格必须在0元与1亿元之间哦"];
        return;
    }

    NSString *postFee = [self formatPrice:postFeeTextField.text];
    if ([postFee doubleValue] > MAX_SHIP_PRICE) {
        [FMCommon alert:@"" message:@"亲，宝贝运费必须小于1000元哦"];
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"亲，您确定要修改价格吗?"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert  setHandler:^{
        [self confirmModify];
    } forButtonAtIndex:1];
    [alert show];
}

- (NSString *)formatPrice:(NSString *)price {
    if (!price || [price isBlank]) {
        return @"00.00";
    }

    NSArray *array = [price componentsSeparatedByString:@"."];
    if ([array count] < 2) {
        return [NSString stringWithFormat:@"%@.00", [array objectAtIndex:0]];
    }

    NSString *str = [array objectAtIndex:1];
    NSString *firstString = [[array objectAtIndex:0] isNotBlank] ? [array objectAtIndex:0] : @"0";
    if ([str length] == 0) {
        return [NSString stringWithFormat:@"%@.00", firstString];
    }

    if ([str length] == 1) {
        return [NSString stringWithFormat:@"%@.%@0", firstString, str];
    }

    if ([str length] > 1) {
        return [NSString stringWithFormat:@"%@.%@", firstString, [str substringToIndex:2]];
    }

    return @"00.00";
}

- (void)confirmModify {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改价格中...";
    FMOrderDetail *order = [_orderList.orders.order objectAtIndex:0];
    UITextField *paymentTextField = [self modifyPaymentTextField];
    UITextField *postFeeTextField = [self modifyPostFeeTextField];
    long long payment = (long long int) ([[self formatPrice:paymentTextField.text] doubleValue] * 100);
    long long postFee = (long long int) ([[self formatPrice:postFeeTextField.text] doubleValue] * 100);
    [FMTradesService modifyItemPrice:order.oid
                           modifyFee:[NSString stringWithFormat:@"%lld", payment]
                     newTransportFee:[NSString stringWithFormat:@"%lld", postFee]
                              result:^(BOOL isSuccess, NSNumber *number, NSString *errMsg) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  if (isSuccess) {
                                      [self refreshSoldController];
                                      [FMCustomStatusBar showStatusMessage:@"修改价格成功" hideAfter:2];
                                      [self.navigationController popViewControllerAnimated:YES];
                                      return;
                                  }
                                  if (errMsg && [errMsg isNotBlank]) {
                                      [FMCommon alert:@"" message:errMsg];
                                      return;
                                  }
                                  [FMCommon alert:@"" message:@"系统忙，请稍后再试"];
                                  return;
                              }];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect shipmentsRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,154}};
    _modifyTableView = [[UITableView alloc] initWithFrame:shipmentsRect style:UITableViewStyleGrouped];
    _modifyTableView.backgroundView = nil;
    _modifyTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _modifyTableView.delegate = self;
    _modifyTableView.dataSource = self;
    _modifyTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _modifyTableView.scrollEnabled = NO;
    //_modifyTableView.hidden = YES;
    [self.view addSubview:_modifyTableView];

    CGRect detailRect = {{0,kNavigationBarHeight + 151},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight - 151}};
    _orderDetailTableView = [[UITableView alloc] initWithFrame:detailRect style:UITableViewStyleGrouped];
    _orderDetailTableView.backgroundView = nil;
    _orderDetailTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _orderDetailTableView.delegate = self;
    _orderDetailTableView.dataSource = self;
    _orderDetailTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //_orderDetailTableView.hidden = YES;
    [self.view addSubview:_orderDetailTableView];

    [self.view bringSubviewToFront:_modifyTableView];
    [self initHideKeyboardButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestOrderInfo];
}

- (void)dealloc {
    _modifyTableView.delegate = nil;
    _modifyTableView.dataSource = nil;
}

- (UITableViewCell *)modifyDescriptionCell {
    UITableViewCell *cell = [_modifyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    return cell;
}

- (UITextField *)modifyPaymentTextField {
    UITableViewCell *cell = [_modifyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:4001];
    return textField;
}

- (UITextField *)modifyPostFeeTextField {
    UITableViewCell *cell = [_modifyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:4002];
    return textField;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *paymentTextField = [self modifyPaymentTextField];
    UITextField *postFeeTextField = [self modifyPostFeeTextField];
    UITableViewCell *cell = [self modifyDescriptionCell];
    NSString *payment = [paymentTextField.text isBlank] ? @"0.00" : [self formatPrice:paymentTextField.text];
    NSString *postFee = [postFeeTextField.text isBlank] ? @"0.00" : [self formatPrice:postFeeTextField.text];
    NSString *total = [NSString stringWithFormat:@"%.2f", [payment doubleValue] + [postFee doubleValue]];
    cell.textLabel.text = [NSString stringWithFormat:@"修改后应付款:￥%@ (含运费:￥%@)", total, postFee];
}

- (void)requestOrderInfo {
    FMOrderDetail *order = [_orderList.orders.order objectAtIndex:0];
    [FMTradesService getTradeInfoBy:order.oid result:^(BOOL isSuccess, id data, NSString *error) {
        [_orderInfo addEntriesFromDictionary:data];
        [_orderDetailTableView reloadData];
        UITextField *textField = [self modifyPaymentTextField];
        [textField becomeFirstResponder];
    }];
}

- (void)refreshSoldController {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [allViewControllers removeObjectAtIndex:([allViewControllers count] - 1)];
    NSUInteger i = [allViewControllers count] - 1;
    UIViewController *soldController = [allViewControllers objectAtIndex:i];
    if (soldController && [soldController isKindOfClass:[FMMySoldTradeViewController class]]) {
        [(FMMySoldTradeViewController *) soldController refreshData];
    }
    return;
}

- (void)initHideKeyboardButton {
    if (_hideKeyboardButton) {
        [_hideKeyboardButton removeFromSuperview];
        _hideKeyboardButton = nil;
    }

    CGRect keyboardRect = {{FM_SCREEN_WIDTH - 51, FM_SCREEN_HEIGHT + 25}, {42, 25}};
    _hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hideKeyboardButton.frame = keyboardRect;
    [_hideKeyboardButton addTarget:self
                            action:@selector(hideKeyboard)
                  forControlEvents:UIControlEventTouchUpInside];
    [_hideKeyboardButton setBackgroundImage:[UIImage imageWithFileName:@"keyboard_btn.png"]
                                   forState:UIControlStateNormal];
    [self.view addSubview:_hideKeyboardButton];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[aNotification.userInfo
            objectForKey:UIKeyboardAnimationCurveUserInfoKey]
            getValue:&animationCurve];
    [[aNotification.userInfo
            objectForKey:UIKeyboardAnimationDurationUserInfoKey]
            getValue:&animationDuration];

    [self hideKeyboardButton:animationDuration];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardBounds = [self.view convertRect:keyboardEndFrame toView:nil];

    [self showKeyboardButton:animationDuration keyboard:keyboardBounds];
}

- (void)hideKeyboardButton:(NSTimeInterval)animationDuration {
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 51, FM_SCREEN_HEIGHT + 25,
                                 42, 25
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
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 51,
                                 self.view.frame.size.height - keyboardBounds.size.height - 25,
                                 42, 25
                         );
                     }
                     completion:nil];
}

- (UIView *)shipmentsFooterView {
    CGRect viewRect = {{0,0},{FM_SCREEN_WIDTH,13}};
    __autoreleasing UIView *footerView = [[UIView alloc] initWithFrame:viewRect];
    footerView.backgroundColor = [UIColor clearColor];
    UIImage *shadowImage = [[UIImage imageNamed:@"item_detail_shadow.png"] resizeImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    CGRect shadowRect = {{0,13 - 6},{FM_SCREEN_WIDTH,3}};
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    shadowImageView.frame = shadowRect;
    shadowImageView.backgroundColor = [UIColor clearColor];
    [footerView addSubview:shadowImageView];
    return footerView;
}

- (float)addressTextHeight {
    NSString *address = [self getFullAddress];
    CGSize size = [address sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height > 19 ? size.height : 19;
}

- (float)buyerDescriptionTextHeight {
    NSString *desc = [_orderInfo objectForKey:@"buyer_message"];
    CGSize size = [desc sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height;
}

- (NSString *)getFullAddress {
    NSMutableArray *addressArray = [NSMutableArray arrayWithCapacity:4];

    NSString *state = [_orderInfo objectForKey:@"receiver_state"];
    NSString *city = [_orderInfo objectForKey:@"receiver_city"];
    NSString *district = [_orderInfo objectForKey:@"receiver_district"];
    NSString *address = [_orderInfo objectForKey:@"receiver_address"];

    if (state && [state isNotBlank]) {
        [addressArray addObject:state];
    }

    if (city && [city isNotBlank]) {
        [addressArray addObject:city];
    }

    if (district && [district isNotBlank]) {
        [addressArray addObject:district];
    }

    if (address && [address isNotBlank]) {
        [addressArray addObject:address];
    }

    return [addressArray componentsJoinedByString:@" "];
}

- (NSString *)getPhone {
    NSString *mobile = [_orderInfo objectForKey:@"receiver_mobile"];
    if (mobile && [mobile isNotBlank]) {
        return mobile;
    }

    NSString *phone = [_orderInfo objectForKey:@"receiver_phone"];
    if (phone && [phone isNotBlank]) {
        return phone;
    }

    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _modifyTableView) {
        return 13;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == _modifyTableView) {
        return [self shipmentsFooterView];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) indexPath.row;
    NSUInteger section = (NSUInteger)indexPath.section;
    if (tableView == _orderDetailTableView) {
        if (section == 0) {
            return 200;
        } else if (section == 1) {
            if (row == 1) {
                float descHeight = [self buyerDescriptionTextHeight];
                if (descHeight < 44) {
                    return 44;
                }
                return descHeight + 25;
            }
        } else if (section == 2) {
            if (row == 0) {
                return [self addressTextHeight] + 25;
            }
        }
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _modifyTableView) {
        return 1;
    }

    if (tableView == _orderDetailTableView) {
        return 4;
    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _modifyTableView) {
        return 3;
    }

    if (tableView == _orderDetailTableView) {
        if (section == 0)  {
            return 1;
        } else if (section == 1) {
            return 3;
        } else if (section == 2) {
            return 3;
        } else if (section == 3) {
            return 3;
        }
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) [indexPath section];
    NSUInteger row = (NSUInteger) [indexPath row];

    if (tableView == _modifyTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor whiteColor];
        double totalPayment = [_orderList.payment doubleValue];
        double payment = totalPayment - [_orderList.post_fee doubleValue];
        NSString *paymentString = [NSString stringWithFormat:@"%.2f", payment];
        if (row == 0) {
            cell.textLabel.text = @"修改价格(元):";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            CGRect fieldRect = {{115,2},{175,40}};
            UITextField *priceTextField = [[UITextField alloc] initWithFrame:fieldRect];
            priceTextField.backgroundColor = [UIColor clearColor];
            priceTextField.font = FMFont(YES, 15.f);
            priceTextField.textAlignment = NSTextAlignmentRight;
            priceTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            priceTextField.tag = 4001;
            priceTextField.delegate = self;
            priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
            priceTextField.text = paymentString;
            [cell.contentView addSubview:priceTextField];
        } else if (row == 1) {
            cell.textLabel.text = @"运费(元):";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            CGRect fieldRect = {{115,2},{175,40}};
            UITextField *postFeeTextField = [[UITextField alloc] initWithFrame:fieldRect];
            postFeeTextField.backgroundColor = [UIColor clearColor];
            postFeeTextField.font = FMFont(YES, 15.f);
            postFeeTextField.textAlignment = NSTextAlignmentRight;
            postFeeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            postFeeTextField.tag = 4002;
            postFeeTextField.delegate = self;
            postFeeTextField.keyboardType = UIKeyboardTypeDecimalPad;
            postFeeTextField.text = _orderList.post_fee;
            [cell.contentView addSubview:postFeeTextField];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"修改后应付款:￥%@ (含运费:￥%@)", [NSString stringWithFormat:@"%.2f", totalPayment], _orderList.post_fee];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        return cell;
    }

    if (tableView == _orderDetailTableView) {
        static NSString *orderIdentifier = @"MySoldOrderIdentifier";
        if (section == 0) {
            FMItemResellCell *orderCell = [tableView dequeueReusableCellWithIdentifier:orderIdentifier];
            if (orderCell == nil) {
                orderCell = [[FMItemResellCell alloc] initWithStyle:UITableViewCellStyleDefault];
                orderCell.selectionStyle = UITableViewCellSelectionStyleNone;
                orderCell.backgroundColor = [UIColor whiteColor];
            }
            [orderCell setData:_orderList type:FMItemResellCellBuyTrade];
            return orderCell;
        }

        static NSString *orderCellIdentifier = @"orderCellIdentifier";
        FMShipmentsItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
        if (!cell) {
            cell = [[FMShipmentsItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:orderCellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.rightLabel.adjustsFontSizeToFitWidth = YES;
        cell.rightLabel.numberOfLines = 1;
        CGRect rightRect = {{90,12},{200,20}};
        cell.rightLabel.frame = rightRect;

        if (section == 1) {
            switch (row) {
                case 0:
                    [cell setLeft:@"买家旺旺ID" right:[_orderInfo objectForKey:@"buyer_nick"]];
                    break;
                case 1:
                    cell.rightLabel.adjustsFontSizeToFitWidth = NO;
                    cell.rightLabel.numberOfLines = 0;
                    CGRect frame = cell.rightLabel.frame;
                    frame.size.height = [self buyerDescriptionTextHeight] > 20 ? [self buyerDescriptionTextHeight] : 20;
                    cell.rightLabel.frame = frame;
                    [cell setLeft:@"买家留言" right:[_orderInfo objectForKey:@"buyer_message"]];
                    break;
                case 2:
                    [cell setLeft:@"买家邮箱" right:[_orderInfo objectForKey:@"buyer_email"]];
                    break;
                default:
                    break;
            }
        } else if (section == 2) {
            switch (row) {
                case 0:
                    cell.rightLabel.adjustsFontSizeToFitWidth = NO;
                    cell.rightLabel.numberOfLines = 0;
                    CGRect frame = cell.rightLabel.frame;
                    frame.size.height = [self addressTextHeight];
                    cell.rightLabel.frame = frame;
                    [cell setLeft:@"收货地址" right:[self getFullAddress]];
                    break;
                case 1:
                    [cell setLeft:@"收货人" right:[_orderInfo objectForKey:@"receiver_name"]];
                    break;
                case 2:
                    [cell setLeft:@"手机" right:[self getPhone]];
                    break;
                default:
                    break;
            }
        } else if (section == 3) {
            switch (row) {
                case 0:
                    [cell setLeft:@"淘宝订单" right:_orderList.tid];
                    break;
                case 1:
                    [cell setLeft:@"支付宝订单" right:[_orderInfo objectForKey:@"alipay_no"]];
                    break;
                case 2:
                    [cell setLeft:@"生成时间" right:[_orderInfo objectForKey:@"modified"]];
                    break;
                default:
                    break;
            }
        }

        return cell;
    }
    return nil;
}

#pragma mark - keyboard handle
- (void)hideKeyboard {
    [[self firstResponderView] resignFirstResponder];
}

- (UIView *)firstResponderView {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponderView = [keyWindow performSelector:@selector(firstResponder)];
    return firstResponderView;
}

@end