//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:30.
//

#import "FMStuffStatusViewController.h"
#import "FMSearchParameter.h"
#import "FMFilterFieldOptionDO.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMStuffStatusViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FMStuffStatusViewController {
    UITableView *_statusTableView;
    NSArray *_statusItems;
    FMSearchParameter *_searchParameter;

    void (^_didSelectBlock)(FMFilterFieldOptionDO *);

}

- (void)initNavigationBar {
    [self setTitle:@"新旧筛选"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
}

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter {
    self = [super init];
    if (self) {
        _searchParameter = searchParameter;
    }

    return self;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableViewRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, self.view.frame.size.height}};
    _statusTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    _statusTableView.delegate = self;
    _statusTableView.dataSource = self;
    _statusTableView.backgroundView = nil;
    _statusTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _statusTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_statusTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _statusItems = [self statusFieldItems];
}

- (void)dealloc {
    _statusTableView.delegate = nil;
    _statusTableView.dataSource = nil;
}

- (NSArray *)statusFieldItems {
    FMFilterFieldOptionDO *unlimitedItem = [[FMFilterFieldOptionDO alloc] init];
    unlimitedItem.title = @"不限";
    unlimitedItem.value = [NSString stringWithFormat:@"%d", FMSearchConditionStuffStatusNoLimit];

    FMFilterFieldOptionDO *newItem = [[FMFilterFieldOptionDO alloc] init];
    newItem.title = @"全新";
    newItem.value = [NSString stringWithFormat:@"%d", FMSearchConditionStuffStatusAllNew];

    FMFilterFieldOptionDO *notAllNewItem = [[FMFilterFieldOptionDO alloc] init];
    notAllNewItem.title = @"非全新";
    notAllNewItem.value = [NSString stringWithFormat:@"%d", FMSearchConditionStuffStatusAllOld];

    NSArray *array = [NSArray arrayWithObjects:unlimitedItem, newItem, notAllNewItem, nil];
    return array;
}

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *optionDO))block {
    _didSelectBlock = block;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _statusItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterStuffStatusTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }

    FMFilterFieldOptionDO *stuffStatus = [_statusItems objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = stuffStatus.title;

    if (_searchParameter._stuffStatus == [stuffStatus.value intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMFilterFieldOptionDO *optionDO = [_statusItems objectAtIndex:(NSUInteger) indexPath.row];
    [_statusTableView reloadData];
    if (_didSelectBlock) {
        _didSelectBlock(optionDO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end