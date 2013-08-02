// 
// Created by henson on 4/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <huoyan/huoyan.h>
#import <iOS_Util/NSDictionary+TBIU_ToObject.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "FMShipmentsViewController.h"
#import "FMSegmentedControl.h"
#import "FMLogisticsCompaniesViewController.h"
#import "FMLogisticsCompanyDO.h"
#import "FMShipmentsItemInfoCell.h"
#import "FMCommon.h"
#import "FMTradesService.h"
#import "NSString+Helper.h"
#import "FMShipmentsService.h"
#import "FMMySoldTradeViewController.h"
#import "FMItemService.h"
#import "FMItemDO.h"
#import "TBMBDefaultRootViewController+TBMBProxy.h"
#import "FMTradeDO.h"
#import "FMSidePanelController.h"
#import "FMItemResellCell.h"
#import "FMStyle.h"

@implementation FMShipmentsViewController {
    UITableView *_shipmentsTableView;
    UITableView *_orderDetailTableView;
    FMSegmentedControl *_segmentedControl;
    UIButton *_hideKeyboardButton;

    FMLogisticsCompanyDO *_companyDO;
    NSString *_outSid;  //快递单号码

@private
    BOOL _needShipments;
    FMOrderList *_orderList;
    long long int _tid;
    NSString *_itemId;
    FMItemDO *_itemDO;
    FMShipmentFrom _from;
}

- (id)init {
    self = [super init];
    if (self) {
        _needShipments = YES;
        _from = FMShipmentDefault;
    }
    return self;
}

- (id)initWithTid:(long long int)tid itemId:(NSString *)itemId from:(FMShipmentFrom)from {
    self = [self init];
    if (self) {
        _tid = tid;
        _itemId = [itemId copy];
        _from = from;
    }
    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"发货信息"];
    self.leftBarButton.hidden = NO;
    [self setRightButtonTitle:@"发货"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    [self.rightBarButton setEnabled:NO];

    CGRect shipmentsRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,164}};
    _shipmentsTableView = [[UITableView alloc] initWithFrame:shipmentsRect style:UITableViewStyleGrouped];
    _shipmentsTableView.backgroundView = nil;
    _shipmentsTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _shipmentsTableView.delegate = self;
    _shipmentsTableView.dataSource = self;
    _shipmentsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _shipmentsTableView.scrollEnabled = NO;
    _shipmentsTableView.hidden = YES;
    [self.view addSubview:_shipmentsTableView];

    CGRect detailRect = {{0,kNavigationBarHeight + 161},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight - 161}};
    _orderDetailTableView = [[UITableView alloc] initWithFrame:detailRect style:UITableViewStyleGrouped];
    _orderDetailTableView.backgroundView = nil;
    _orderDetailTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _orderDetailTableView.delegate = self;
    _orderDetailTableView.dataSource = self;
    _orderDetailTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _orderDetailTableView.hidden = YES;
    [self.view addSubview:_orderDetailTableView];

    [self initHideKeyboardButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestItemDetail];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    UITableViewCell *cell = [_shipmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1002];
    _outSid = textField.text;
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

- (void)releaseViews {
    [super releaseViews];

    _shipmentsTableView = nil;
    _orderDetailTableView = nil;
}

- (void)dealloc {
    _shipmentsTableView.delegate = nil;
    _shipmentsTableView.dataSource = nil;
    _orderDetailTableView.delegate = nil;
    _orderDetailTableView.dataSource = nil;
}

- (void)requestItemDetail {
    [self showPageLoadingView];
    [FMItemService getItemDetail:_itemId result:^(BOOL isSuccess, FMItemDetailResponseDO *detailResponseDO, NSString *error) {
        if (isSuccess) {
            _itemDO = detailResponseDO.item;
            if (detailResponseDO.item.offline == FMItemTradeTypeF2F) {
                _shipmentsTableView.hidden = YES;
                _orderDetailTableView.frame = CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight);
            } else {
                _shipmentsTableView.hidden = NO;
            }

            [self requestOrderInfo];
            return;
        }
        __weak FMShipmentsViewController *weakSelf = self;
        [self showRefreshPage:^{
            [weakSelf requestItemDetail];
        }];
    }];
}

- (void)requestOrderInfo {
    [FMTradesService getTradeInfoBy:[self getTid] result:^(BOOL isSuccess, id data, NSString *error) {
        _orderList = [data toObjectWithClass:[FMOrderList class]];
        if (_from == FMShipmentMessage && [self isWaitConfirmGoods]) {
            [self setTitle:@"订单信息(已发货)"];
            self.rightBarButton.hidden = YES;
            _shipmentsTableView.hidden = YES;
            _orderDetailTableView.frame = CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight);
        } else {
            if ([self isWaitConfirmGoods]) {
                [self hideShipmentHeader];
                FMOrderDetail *orderDetail = [_orderList.orders.order objectAtIndex:0];
                _outSid = orderDetail.invoice_no ?: @"";
                if (orderDetail.logistics_company && [orderDetail.logistics_company isNotBlank]) {
                    [self requestLogisticsCompany];
                }
            }
        }

        _orderDetailTableView.hidden = NO;
        [self.rightBarButton setEnabled:YES];
        [_orderDetailTableView reloadData];
        [self removePageLoadingView];
    }];
}

- (void)requestLogisticsCompany {
    [FMShipmentsService getLogisticsCompanies:^(BOOL isSuccess, id companies, NSString *string) {
        if (isSuccess) {
            FMOrderDetail *orderDetail = [_orderList.orders.order objectAtIndex:0];
            for (int i=0; i< [companies count]; i++) {
                FMLogisticsCompanyDO *companyDO = [[companies objectAtIndex:(NSUInteger) i] toObjectWithClass:[FMLogisticsCompanyDO class]];
                if ([companyDO.name isEqualToString:orderDetail.logistics_company]) {
                    _companyDO = [companyDO copy];
                    break;
                }
            }
            [_shipmentsTableView reloadData];
            return;
        }
    }];
}

- (NSString *)getTid {
    return [NSString stringWithFormat:@"%lld", _tid];
}

- (BOOL)isValidCode {
    if (!_companyDO.reg_mail_no || [_companyDO.reg_mail_no isBlank]) {
        return YES;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _companyDO.reg_mail_no];
    return [predicate evaluateWithObject:_outSid];
}

- (void)rightAction:(id)sender {
    [super rightAction:sender];

    NSString *tid = [NSString stringWithFormat:@"%lld", [_orderList.tid longLongValue]];
    if ([self isWaitConfirmGoods] || (!_shipmentsTableView.hidden && _needShipments)) {
        if (!_companyDO) {
            [FMCommon alert:@"" message:@"亲，请选择快递公司"];
            return;
        }

        if (!_outSid || [_outSid isBlank]) {
            [FMCommon alert:@"" message:@"亲，请扫描或输入快递单号"];
            return;
        }

        if (![self isValidCode]) {
            [FMCommon alert:@"" message:@"亲，您的订单号不合法"];
            return;
        }
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"发货中...";

    if ([self isWaitConfirmGoods]) {
        [FMShipmentsService modifyShipment:tid
                          logisticsCompany:_companyDO
                                    outSid:_outSid
                                    result:^(BOOL isSuccess, BOOL result, NSString *string) {
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        if (isSuccess && result) {
                                            [FMCommon showToast:[UIApplication sharedApplication].keyWindow text:@"修改发货成功"];
                                            [self refreshSoldController];
                                            [self.navigationController popViewControllerAnimated:YES];
                                            return;
                                        }

                                        if (string) {
                                            [FMCommon alert:@"" message:string];
                                            return;
                                        }
                                        [FMCommon alert:@"" message:@"系统忙，请稍后再试"];
                                    }];
        return;
    }

    if (!_shipmentsTableView.hidden && _needShipments) {
        [FMShipmentsService offlineShip:tid logisticsCompany:_companyDO
                                 outSid:_outSid
                                 result:^(BOOL isSuccess, BOOL result, NSString *string) {
                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                     if (isSuccess && result) {
                                         [FMCommon showToast:[UIApplication sharedApplication].keyWindow text:@"发货成功"];
                                         [self refreshSoldController];
                                         [self.navigationController popViewControllerAnimated:YES];
                                         return;
                                     }

                                     if (string) {
                                         [FMCommon alert:@"" message:string];
                                         return;
                                     }
                                     [FMCommon alert:@"" message:@"系统忙，请稍后再试"];
                                 }];

        return;
    }

    [FMShipmentsService dummyShip:tid result:^(BOOL isSuccess, BOOL result, NSString *string) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (isSuccess && result) {
            [FMCommon showToast:[UIApplication sharedApplication].keyWindow text:@"发货成功"];
            [self refreshSoldController];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (string) {
            [FMCommon alert:@"" message:string];
            return;
        }
        [FMCommon alert:@"" message:@"系统忙，请稍后再试"];
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

- (void)shipmentSegmentChanged:(FMSegmentedControlItem *)item {
    if (item.tag == 1) {
        [self showShipment:YES];
    } else if (item.tag == 2) {
        [self showShipment:NO];
    }
}

- (void)hideShipmentHeader {
    CGRect frame = _orderDetailTableView.frame;
    frame.origin.y = _shipmentsTableView.frame.size.height;
    frame.size.height += 41;
    _orderDetailTableView.frame = frame;
    [_shipmentsTableView reloadData];
}

- (void)showShipment:(BOOL)isShow {
    CGRect shipmentsRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,154}};
    CGRect frame = {{0,kNavigationBarHeight},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight}};
    if (isShow) {
        frame.origin.y += 154;
        frame.size.height -= 154;
        _needShipments = YES;
    } else {
        shipmentsRect.size.height = 60;
        frame.origin.y += 60;
        frame.size.height -= 60;
        _needShipments = NO;
    }
    _orderDetailTableView.frame = frame;
    _shipmentsTableView.frame = shipmentsRect;
    [_shipmentsTableView reloadData];
}

- (float)addressTextHeight {
    NSString *address = [self getFullAddress];
    CGSize size = [address sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height > 19 ? size.height : 19;
}

- (float)buyerDescriptionTextHeight {
    CGSize size = [_orderList.buyer_message sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height;
}

- (UIView *)shipmentsHeaderView {
    FMShipmentsViewController *selfProxy = self.proxyObject;
    CGRect viewRect = {{0,0},{300,55}};
    __autoreleasing UIView *headerView = [[UIView alloc] initWithFrame:viewRect];
    headerView.backgroundColor = [UIColor clearColor];

    FMSegmentedControlItem *item1 = [[FMSegmentedControlItem alloc] initWithTitle:@"输入物流信息"
                                                                    hasArrowImage:NO isRepeatTouch:NO];
    item1.tag = 1;
    FMSegmentedControlItem *item2 = [[FMSegmentedControlItem alloc] initWithTitle:@"无需物流"
                                                                    hasArrowImage:NO isRepeatTouch:NO];
    item2.tag = 2;
    NSArray *items = @[item1, item2];
    CGRect segmentedControlRect = {{10, 10}, {300, 44}};
    if (!_segmentedControl) {
        _segmentedControl = [[FMSegmentedControl alloc] initWithFrame:segmentedControlRect];
        [_segmentedControl setSegmentedItems:items];
        [_segmentedControl setSegmentChangedAction:^(FMSegmentedControlItem *item) {
            [selfProxy shipmentSegmentChanged:item];
        }];
        _segmentedControl.backgroundColor = [UIColor clearColor];
    }
    [headerView addSubview:_segmentedControl];
    [_segmentedControl setSelectedIndex:_needShipments ? 0 : 1];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _shipmentsTableView) {
        if ([self isWaitConfirmGoods]) {
            return 10;
        }
        return _needShipments ? 61 : 41;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _shipmentsTableView) {
        return 13;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _shipmentsTableView) {
        if ([self isWaitConfirmGoods]) {
            return nil;
        }
        return [self shipmentsHeaderView];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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
    if (tableView == _shipmentsTableView) {
        return 1;
    }

    if (tableView == _orderDetailTableView) {
        return 4;
    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _shipmentsTableView) {
        return _needShipments ? 2 : 0;
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

- (UIButton *)scanButton {
    CGRect scanRect = {{255, 2}, {40, 40}};
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setImage:[UIImage imageWithFileName:@"post_barscan_icon.png"] forState:UIControlStateNormal];
    scanButton.frame = scanRect;
    [scanButton addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    return scanButton;
}

- (void)scanAction {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        huoyanViewController *huoyanController = [[huoyanViewController alloc] init];
        [huoyanController setDidFindBarCode:^(NSString *code) {
            [self setShipmentsNumber:code];
        }];
        [self.fmSidePanelController presentViewController:huoyanController
                                                 animated:YES
                                               completion:nil];
    } else {
        [FMCommon alert:@"" message:@"亲，您的设备暂不支持设备功能哦!"];
    }
}

- (void)setShipmentsNumber:(NSString *)code {
    UITableViewCell *cell = [_shipmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1002];
    textField.text = code;
    _outSid = textField.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) [indexPath section];
    NSUInteger row = (NSUInteger) [indexPath row];

    if (tableView == _shipmentsTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor whiteColor];

        if (row == 0) {
            cell.textLabel.text = @"物流公司:";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, 175, 20)];
            companyLabel.textAlignment = NSTextAlignmentRight;
            companyLabel.backgroundColor = [UIColor clearColor];
            companyLabel.font = FMFont(YES, 15.f);
            companyLabel.tag = 1001;
            companyLabel.text = _companyDO ? _companyDO.name : @"";
            [cell.contentView addSubview:companyLabel];
        } else if (row == 1) {
            cell.textLabel.text = @"运单号码:";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:[self scanButton]];

            CGRect fieldRect = {{90,2},{165,40}};
            UITextField *shipmentsNOField = [[UITextField alloc] initWithFrame:fieldRect];
            shipmentsNOField.backgroundColor = [UIColor clearColor];
            shipmentsNOField.font = FMFont(YES, 15.f);
            shipmentsNOField.textAlignment = NSTextAlignmentRight;
            shipmentsNOField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            shipmentsNOField.tag = 1002;
            shipmentsNOField.delegate = self;
            shipmentsNOField.text = _outSid ?: @"";
            [cell.contentView addSubview:shipmentsNOField];
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
                    [cell setLeft:@"买家旺旺ID" right:_orderList.buyer_nick];
                    break;
                case 1:
                    cell.rightLabel.adjustsFontSizeToFitWidth = NO;
                    cell.rightLabel.numberOfLines = 0;
                    CGRect frame = cell.rightLabel.frame;
                    frame.size.height = [self buyerDescriptionTextHeight] > 20 ? [self buyerDescriptionTextHeight] : 20;
                    cell.rightLabel.frame = frame;
                    [cell setLeft:@"买家留言" right:_orderList.buyer_message];
                    break;
                case 2:
                    [cell setLeft:@"买家邮箱" right:_orderList.buyer_email];
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
                    [cell setLeft:@"收货人" right:[self getReceiver]];
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
                    [cell setLeft:@"支付宝订单" right:_orderList.alipay_no];
                    break;
                case 2:
                    [cell setLeft:@"生成时间" right:_orderList.modified];
                    break;
                default:
                    break;
            }
        }

        return cell;
    }

    return nil;
}

- (NSString *)getReceiver {
    if ([self isTradeTypeF2FORAnyway]) {
        if ([self isTradeTypeF2F]) {
            if ([_orderList.receiver_address isBlank]) {
                return @"";
            }
            NSArray *array = [_orderList.receiver_address componentsSeparatedByString:@";"];
            if ([array count] > 0) {
                return [array objectAtIndex:0];
            }
        }
    }

    return _orderList.receiver_name;
}

- (NSString *)getPhone {
    if ([self isTradeTypeF2FORAnyway]) {
        if ([self isTradeTypeF2F]) {
            if ([_orderList.receiver_address isBlank]) {
                return @"";
            }

            NSArray *array = [_orderList.receiver_address componentsSeparatedByString:@";"];
            if ([array count] > 1) {
                return [array objectAtIndex:1];
            }
        }
    }

    NSString *mobile = _orderList.receiver_mobile;
    if (mobile && [mobile isNotBlank]) {
        return mobile;
    }

    NSString *phone = _orderList.receiver_phone;
    if (phone && [phone isNotBlank]) {
        return phone;
    }

    return @"";
}

- (BOOL)isTradeTypeF2FORAnyway {
    return _itemDO.offline == FMItemTradeTypeF2F ||  _itemDO.offline == FMItemTradeTypeAnyway;
}

- (BOOL)isTradeTypeF2F {
    NSString *state = _orderList.receiver_state;
    NSString *city = _orderList.receiver_city;
    NSString *district = _orderList.receiver_district;
    if (([state isBlank] && [city isBlank] && [district isBlank])
            || _itemDO.offline == FMItemTradeTypeF2F) {
        return YES;
    }
    return NO;
}

- (NSString *)getFullAddress {
    NSString *state = _orderList.receiver_state;
    NSString *city = _orderList.receiver_city;
    NSString *district = _orderList.receiver_district;
    NSString *address = _orderList.receiver_address;
    if ([self isTradeTypeF2FORAnyway]) {
        if ([self isTradeTypeF2F]) {
            return @"";
        }
    }

    NSMutableArray *addressArray = [NSMutableArray arrayWithCapacity:4];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSUInteger row = (NSUInteger) [indexPath row];
    if (tableView == _shipmentsTableView) {
        if (row == 0) {
            FMLogisticsCompaniesViewController *viewController = [[FMLogisticsCompaniesViewController alloc] init];
            viewController.hidesBottomBarWhenPushed = YES;
            [viewController setSelectedAction:^(FMLogisticsCompanyDO *companyDO) {
                _companyDO = [companyDO copy];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UILabel *companyLabel = (UILabel *)[cell.contentView viewWithTag:1001];
                companyLabel.text = companyDO.name;
            }];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        return;
    }
}

- (BOOL)isWaitConfirmGoods {
    if ([_orderList.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"]) {
        return YES;
    }
    return NO;
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