// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import "FMDeliveryAddressViewController.h"
#import "FMItemDeliveryInfoCell.h"
#import "FMItemService.h"

@interface FMDeliveryAddressViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FMDeliveryAddressViewController {
    UITableView *_tableView;
    NSMutableArray *_deliveries;

    void (^_selectActionBlock)(FMDeliveryDO *);
}

- (id)init {
    self = [super init];
    if (self) {
        _deliveries = [NSMutableArray array];
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"送货地址"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kStatusBarHeight - kNavigationBarHeight}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.hidden = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = FMColorWithRed(231, 230, 226);
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestDelivery];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)setSelectAction:(void (^)(FMDeliveryDO *))block {
    _selectActionBlock = block;
}

- (void)requestDelivery {
    [self showPageLoadingView];
    __weak FMDeliveryAddressViewController *selfWeak = self;
    [FMItemService getDeliveryInfoList:^(BOOL isSuccess, FMDeliveryDOList *deliveryDOList, NSString *errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [_deliveries removeAllObjects];
                [_deliveries addObjectsFromArray:deliveryDOList.addressList];
                [_tableView reloadData];
                [self removePageLoadingView];
                _tableView.hidden = NO;
                return;
            }
            [self showRefreshPage:^{
                [selfWeak requestDelivery];
            }];
        });
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMDeliveryDO *deliveryDO = [_deliveries objectAtIndex:(NSUInteger) indexPath.row];
    return [FMItemDeliveryInfoCell cellHeight:deliveryDO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_deliveries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DeliveryCell";
    FMItemDeliveryInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FMItemDeliveryInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = FMColorWithRed(245, 245, 241);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    FMDeliveryDO *deliveryDO = [_deliveries objectAtIndex:(NSUInteger) indexPath.row];
    [cell setDeliveryDO:deliveryDO];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    FMDeliveryDO *deliveryDO = [_deliveries objectAtIndex:(NSUInteger) indexPath.row];
    if (_selectActionBlock) {
        _selectActionBlock(deliveryDO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end