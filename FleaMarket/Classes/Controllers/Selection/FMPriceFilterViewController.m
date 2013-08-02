//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:28.
//

#import "FMPriceFilterViewController.h"
#import "FMSearchParameter.h"
#import "FMFilterFieldOptionDO.h"
#import "NSString+Helper.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

#define kPriceMaxLength  8

@interface FMPriceFilterViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation FMPriceFilterViewController {
    UITableView *_priceTableView;
    FMSearchParameter *_searchParameter;
    NSArray *_prices;

    void (^_didSelectBlock)(FMFilterFieldOptionDO *, FMFilterFieldOptionDO *);

    UITextField *_startPriceField;
    UITextField *_endPriceField;

    FMFilterFieldOptionDO *_optionDOStart;
    FMFilterFieldOptionDO *_optionDOEnd;

    BOOL _isCustom;
}

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter {
    self = [super init];
    if (self) {
        _optionDOStart = [FMFilterFieldOptionDO objectWithTitle:@"" value:[NSString stringWithFormat:@"%@", searchParameter.startPrice]];
        _optionDOEnd = [FMFilterFieldOptionDO objectWithTitle:@"" value:[NSString stringWithFormat:@"%@", searchParameter.endPrice]];
        _isCustom = YES;
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"价格筛选"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    [self setRightButtonTitle:@"确定"];

    CGRect tableViewRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,self.view.frame.size.height}};
    _priceTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    _priceTableView.delegate = self;
    _priceTableView.dataSource = self;
    _priceTableView.backgroundView = nil;
    _priceTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _priceTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_priceTableView];
}

- (NSArray *)priceFieldItems {
    FMFilterFieldOptionDO *item0 = [FMFilterFieldOptionDO objectWithTitle:@"不限"
                                                                    value:[NSString stringWithFormat:@"%d", 0]];

    FMFilterFieldOptionDO *item100 = [FMFilterFieldOptionDO objectWithTitle:@"100元以下"
                                                                      value:[NSString stringWithFormat:@"%d", 10000]];

    FMFilterFieldOptionDO *item300 = [FMFilterFieldOptionDO objectWithTitle:@"300元以下"
                                                                      value:[NSString stringWithFormat:@"%d", 30000]];

    FMFilterFieldOptionDO *item500 = [FMFilterFieldOptionDO objectWithTitle:@"500元以下"
                                                                      value:[NSString stringWithFormat:@"%d", 50000]];

    FMFilterFieldOptionDO *item1000 = [FMFilterFieldOptionDO objectWithTitle:@"1000元以下"
                                                                       value:[NSString stringWithFormat:@"%d",
                                                                                       100000]];

    FMFilterFieldOptionDO *item3000 = [FMFilterFieldOptionDO objectWithTitle:@"3000元以下"
                                                                       value:[NSString stringWithFormat:@"%d",
                                                                                       300000]];

    NSArray *array = [NSArray arrayWithObjects:item0,item100,item300,item500,item1000,item3000,nil];
    return array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _prices = [self priceFieldItems];
    [_priceTableView reloadData];
}

- (void)rightAction:(id)sender {
    if ([_startPriceField isFirstResponder] || [_endPriceField isFirstResponder]) {
        [self setCustomPriceData];
    }
    long long endPrice = [_endPriceField.text unsignedLongLongValue];
    long long startPrice = [_startPriceField.text unsignedLongLongValue];
    if (endPrice != 0 && endPrice < startPrice) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"亲，起始价格必须小于结束价格哦！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_didSelectBlock) {
        _didSelectBlock(_optionDOStart, _optionDOEnd);
    }
    [self leftAction:sender];
}

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *optionDO, FMFilterFieldOptionDO *))block {
    if (block) {
        _didSelectBlock = block;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _prices.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterPriceTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }

    if (indexPath.row < _prices.count) {
        FMFilterFieldOptionDO *optionDO = [_prices objectAtIndex:(NSUInteger) indexPath.row];
        cell.textLabel.text = optionDO.title;
        if ([_optionDOEnd.value intValue] == [optionDO.value intValue]
                && [_optionDOStart.value intValue] == 0) {
            _isCustom = NO;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        [self getCustomPriceCell:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _prices.count) {
        _optionDOEnd = [_prices objectAtIndex:(NSUInteger) indexPath.row];
        _optionDOStart = nil;
        _startPriceField.text = @"";
        _endPriceField.text = @"";
    } else {
        [self setCustomPriceData];
    }
    [_priceTableView reloadData];

    [_startPriceField resignFirstResponder];
    [_endPriceField resignFirstResponder];
    [_priceTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)getCustomPriceCell:(UIView *)cell {
    if (cell.subviews.count > 4)
        return;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, 115, 24)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [FMFontSize instance].cellLabelSize;
    label.textColor = [FMColor instance].cellColor;
    label.text = @"自定义区间(元)";
    [cell addSubview:label];

    _startPriceField = [[UITextField alloc] initWithFrame:CGRectMake(140, 10, 70, 24)];
    _startPriceField.backgroundColor = [UIColor clearColor];
    _startPriceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _startPriceField.textAlignment = NSTextAlignmentCenter;
    _startPriceField.keyboardType = UIKeyboardTypeNumberPad;
    _startPriceField.delegate = self;
    _startPriceField.placeholder = @"起始价格";
    _startPriceField.font = FMFont(NO, 14.f);
    _startPriceField.borderStyle = UITextBorderStyleLine;
    long long value = [_optionDOStart.value intValue];
    if (_isCustom && value > 0) {
        _startPriceField.text = [NSString stringWithFormat:@"%lld", value / 100];
    }
    [cell addSubview:_startPriceField];

    UIView *view = [[UILabel alloc] initWithFrame:CGRectMake(215, 21, 10, 1)];
    view.backgroundColor = [UIColor blackColor];
    [cell addSubview:view];

    _endPriceField = [[UITextField alloc] initWithFrame:CGRectMake(230, 10, 70, 24)];
    _endPriceField.backgroundColor = [UIColor clearColor];
    _endPriceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _endPriceField.textAlignment = NSTextAlignmentCenter;
    _endPriceField.keyboardType = UIKeyboardTypeNumberPad;
    _endPriceField.delegate = self;
    _endPriceField.placeholder = @"结束价格";
    _endPriceField.font = FMFont(NO, 14.f);
    _endPriceField.borderStyle = UITextBorderStyleLine;
    value = [_optionDOEnd.value intValue];
    if (_isCustom && value > 0) {
        _endPriceField.text = [NSString stringWithFormat:@"%lld", value / 100];
    }
    [cell addSubview:_endPriceField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string; {
    if ([string isEqualToString:@"\n"])
        return YES;

    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([toBeString length] > kPriceMaxLength) {
        textField.text = [toBeString substringToIndex:kPriceMaxLength];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"亲，您输入的价格超出范围！"
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_priceTableView setContentOffset:CGPointMake(0, 150) animated:YES];
}

BOOL isScroll;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScroll = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isScroll && ([_startPriceField isFirstResponder] || [_endPriceField isFirstResponder])) {
        isScroll = NO;
        [_startPriceField resignFirstResponder];
        [_endPriceField resignFirstResponder];
        [_priceTableView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0];
        [self setCustomPriceData];
    }
}

- (void)reloadTableView {
    [_priceTableView reloadData];
}

- (void)setCustomPriceData {
    if ([_startPriceField.text longLongValue] > 0 || [_endPriceField.text longLongValue] > 0) {
        _optionDOStart = [FMFilterFieldOptionDO objectWithTitle:@"" value:[NSString stringWithFormat:@"%@00", _startPriceField.text]];
        _optionDOEnd = [FMFilterFieldOptionDO objectWithTitle:@"" value:[NSString stringWithFormat:@"%@00", _endPriceField.text]];
    }
}

@end