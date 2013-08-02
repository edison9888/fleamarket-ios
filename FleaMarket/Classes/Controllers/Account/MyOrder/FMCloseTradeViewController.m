// 
// Created by henson on 4/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBProgressHUD/MBProgressHUD.h>
#import "FMCloseTradeViewController.h"
#import "FMItemService.h"
#import "FMCustomStatusBar.h"
#import "FMMySoldTradeViewController.h"
#import "FMCommon.h"
#import "NSString+Helper.h"
#import "FMTradeDO.h"
#import "FMTradesService.h"
#import "FMStyle.h"

@interface FMCloseTradeViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FMCloseTradeViewController {
    UITableView *_tableView;
    NSArray *_reasonArray;
    NSInteger _selectedRow;
@private
    FMOrderList *_orderList;
}

@synthesize orderList = _orderList;

- (id)init {
    self = [super init];
    if (self) {
        _reasonArray = @[
                @"未及时付款",
                @"买家联系不上",
                @"谢绝还价",
                @"商品瑕疵",
                @"协商不一致",
                @"买家不想买",
                @"与买家协商一致"];
        _selectedRow = -1;
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"关闭交易"];
    self.leftBarButton.hidden = NO;
    [self setRightButtonTitle:@"确定"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight - 20}};
    _tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)releaseViews {
    [super releaseViews];

    _tableView = nil;
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)rightAction:(id)sender {
    [super rightAction:sender];
    if (_selectedRow < 0) {
        [FMCommon alert:@"" message:@"亲，请选择关闭交易原因哦！"];
        return;
    }
    [self requestCloseTrade];
}

- (void)requestCloseTrade {
    if ([_orderList.tid isBlank]) {
        [FMCommon alert:@"" message:@"亲，您的关闭的交易不存在哦！"];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"关闭交易中...";
    [FMTradesService closeTrade:_orderList.tid
                    closeReason:[_reasonArray objectAtIndex:(NSUInteger) _selectedRow]
                         result:^(BOOL isSuccess, NSNumber *number, NSString *errMsg) {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             if (isSuccess) {
                                 [self refreshSoldController];
                                 [FMCustomStatusBar showStatusMessage:@"关闭交易成功" hideAfter:2];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_reasonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CloseReasonCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == _selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [_reasonArray objectAtIndex:(NSUInteger) indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedRow = (NSUInteger) indexPath.row;
    [tableView reloadData];
}

@end