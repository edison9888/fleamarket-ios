// 
// Created by henson on 4/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <iOS_Util/NSDictionary+TBIU_ToObject.h>
#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import "FMLogisticsCompaniesViewController.h"
#import "FMShipmentsService.h"
#import "FMLogisticsCompanyDO.h"
#import "FMStyle.h"

@implementation FMLogisticsCompaniesViewController {
    UITableView *_tableView;
    NSMutableArray *_companies;
    void (^_selectedAction)(FMLogisticsCompanyDO *);
}

@synthesize selectedAction = _selectedAction;

- (id)init {
    self = [super init];
    if (self) {
        _companies = [[NSMutableArray alloc] initWithCapacity:20];
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"物流公司"];
    self.leftBarButton.hidden = NO;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight}};
    _tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestCompanies];
}

- (void)releaseViews {
    [super releaseViews];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)requestCompanies {
    [self showPageLoadingView];
    FMLogisticsCompaniesViewController *proxy = self.proxyObject;
    [FMShipmentsService getLogisticsCompanies:^(BOOL b, id o, NSString *string) {
        if (b) {
            [_companies addObjectsFromArray:o];
            [_tableView reloadData];
            [self removePageLoadingView];
            _tableView.hidden = NO;
            return;
        }
        [self showRefreshPage:^{
            [proxy requestCompanies];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_companies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }

    FMLogisticsCompanyDO *companyDO = [[_companies objectAtIndex:(NSUInteger) indexPath.row] toObjectWithClass:[FMLogisticsCompanyDO class]];
    cell.textLabel.text = companyDO.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FMLogisticsCompanyDO *companyDO = [[_companies objectAtIndex:(NSUInteger) indexPath.row] toObjectWithClass:[FMLogisticsCompanyDO class]];
    if (_selectedAction && companyDO) {
        _selectedAction(companyDO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end