// 
// Created by henson on 5/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMOrderDetailViewController.h"
#import "FMTradesService.h"
#import "NSString+Helper.h"
#import "FMItemResellCell.h"
#import "FMShipmentsItemInfoCell.h"
#import "FMTradeDO.h"
#import "FMStyle.h"

@implementation FMOrderDetailViewController {
    FMOrderList *_orderList;
    long long int _tid;
    NSString *_itemId;
    UITableView *_orderDetailTableView;
}

- (id)initWithTid:(long long int)tid itemId:(NSString *)itemId {
    self = [self init];
    if (self) {
        _tid = tid;
        _itemId = [itemId copy];
    }
    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"订单信息"];
    self.leftBarButton.hidden = NO;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect detailRect = {{0,kNavigationBarHeight},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight}};
    _orderDetailTableView = [[UITableView alloc] initWithFrame:detailRect style:UITableViewStyleGrouped];
    _orderDetailTableView.backgroundView = nil;
    _orderDetailTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _orderDetailTableView.delegate = self;
    _orderDetailTableView.dataSource = self;
    _orderDetailTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _orderDetailTableView.hidden = YES;
    [self.view addSubview:_orderDetailTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestOrderInfo];
}

- (void)releaseViews {
    [super releaseViews];

    _orderDetailTableView = nil;
}

- (void)dealloc {
    _orderDetailTableView.delegate = nil;
    _orderDetailTableView.dataSource = nil;
}

- (void)requestOrderInfo {
    [self showPageLoadingView];
    [FMTradesService getTradeInfoBy:[self getTid] result:^(BOOL isSuccess, id data, NSString *error) {
        _orderList = [data toObjectWithClass:[FMOrderList class]];

        [self removePageLoadingView];
        [_orderDetailTableView reloadData];
        _orderDetailTableView.hidden = NO;
    }];
}

- (NSString *)getTid {
    return [NSString stringWithFormat:@"%lld", _tid];
}

- (float)addressTextHeight {
    NSString *address = [self getFullAddress];
    CGSize size = [address sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height;
}

- (float)buyerDescriptionTextHeight {
    CGSize size = [_orderList.buyer_message sizeWithFont:FMFont(YES, 15.f) constrainedToSize:CGSizeMake(200,ULONG_MAX)];
    return size.height;
}

- (NSString *)getPhone {
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

- (NSString *)getFullAddress {
    NSMutableArray *addressArray = [NSMutableArray arrayWithCapacity:4];

    NSString *state = _orderList.receiver_state;
    NSString *city = _orderList.receiver_city;
    NSString *district = _orderList.receiver_district;
    NSString *address = _orderList.receiver_address;

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
    if (tableView == _orderDetailTableView) {
        return 4;
    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

    if (tableView == _orderDetailTableView) {
        static NSString *orderIdentifier = @"OrderDetailCellIdentifier";
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
                    [cell setLeft:@"收货人" right:_orderList.receiver_name];
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

@end