// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <MBMvc/TBMBBind.h>
#import "FMPostOptionalInfoView.h"
#import "FMPostTextIndicationView.h"
#import "FMTextView.h"
#import "FMItemDO.h"
#import "NSString+Helper.h"
#import "TBMBDefaultReceiverImpl.h"
#import "FMBaseTableViewCell.h"
#import "FMPostPickerView.h"

#define kPostUsernameMaxLength (15)
#define kPostPostFeeMaxValue (1000)

@interface FMPostOptionalInfoView () <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation FMPostOptionalInfoView {
    FMPostTextIndicationView *_textIndicationView;
    FMTextView *_descriptionTextView;

    UITextField *_userTextField;
    UITextField *_phoneTextField;
    UITextField *_postFeeTextField;
    UILabel *_postFeePromptLabel;

    FMPostPickerView *_offlinePickerView;
    FMPostPickerView *_staffStatusPickerView;

    FMItemDO *_itemDO;

TBMBDefaultReceiverImpl

@synthesize textIndicationView = _textIndicationView;
@synthesize itemDO = _itemDO;

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        _itemDO = itemDO;

        TBMBAutoBindingKeyPath(self);
        [[TBMBGlobalFacade instance] subscribeNotification:self];

        CGRect downIndicationRect = {{0, 0}, {FM_SCREEN_WIDTH, 40}};
        FMPostTextIndicationView *textIndicationView = [[FMPostTextIndicationView alloc] initWithFrame:downIndicationRect
                                                                                                  type:FMPostIndicationTypeDown];
        textIndicationView.backgroundColor = [UIColor clearColor];
        _textIndicationView = textIndicationView;

        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableHeaderView = textIndicationView;
        self.tableFooterView = [self tableFooterView];
        self.showsVerticalScrollIndicator = NO;
        self.sectionFooterHeight = 0.f;
        self.sectionHeaderHeight = 0.f;

        _userTextField = [self userTextField];
        _phoneTextField = [self phoneTextField];
        _postFeeTextField = [self postFeeTextField];
        _postFeePromptLabel = [self postFeePromptLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_userTextField];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_phoneTextField];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_postFeeTextField];

        _offlinePickerView = [self offlinePickerView];
        _staffStatusPickerView = [self stuffStatusPickerView];
    }

    return self;
}

- (void)refreshView {
    [self reloadData];
    _userTextField.text = _itemDO.contacts;
    _phoneTextField.text = _itemDO.phone;
    _postFeeTextField.text = _itemDO.postPrice;
    _descriptionTextView.text = _itemDO.description;
}

TBMBWhenThisKeyPathChange(itemDO, categoryId) {
    FMBaseTableViewCell *cell = (FMBaseTableViewCell *) [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = [_itemDO categoryName];
}

TBMBWhenThisKeyPathChange(itemDO, area) {
    [self refreshLocationCell];
}

TBMBWhenThisKeyPathChange(itemDO, province) {
    [self refreshLocationCell];
}

TBMBWhenThisKeyPathChange(itemDO, city) {
    [self refreshLocationCell];
}

TBMBWhenThisKeyPathChange(itemDO, offline) {
    [self reloadOfflineCell];
}

TBMBWhenThisKeyPathChange(itemDO, stuffStatus) {
    [self reloadStuffStatusCell];
}

- (void)refreshLocationCell {
    FMBaseTableViewCell *cell = (FMBaseTableViewCell *) [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    cell.detailTextLabel.text = [_itemDO getLocationText];
    [cell setNeedsLayout];
}

- (void)reloadOfflineCell {
    FMBaseTableViewCell *cell = (FMBaseTableViewCell *) [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.detailTextLabel.text = [_itemDO getTradeTypeString];
}

- (void)reloadStuffStatusCell {
    FMBaseTableViewCell *cell = (FMBaseTableViewCell *) [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = [_itemDO getStuffStatusString];
}

- (FMPostPickerView *)offlinePickerView {
    CGRect pickerRect = {{0, FM_SCREEN_HEIGHT}, {FM_SCREEN_WIDTH, 200}};
    FMPostPickerView *offlinePickerView = [[FMPostPickerView alloc] initWithFrame:pickerRect];
    offlinePickerView.delegate = self;
    offlinePickerView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:offlinePickerView];
    return offlinePickerView;
}

- (FMPostPickerView *)stuffStatusPickerView {
    CGRect pickerRect = {{0, FM_SCREEN_HEIGHT}, {FM_SCREEN_WIDTH, 200}};
    FMPostPickerView *stuffStatusPickerView = [[FMPostPickerView alloc] initWithFrame:pickerRect];
    stuffStatusPickerView.delegate = self;
    stuffStatusPickerView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:stuffStatusPickerView];
    return stuffStatusPickerView;
}

- (FMTextView *)descriptionTextView {
    if (_descriptionTextView) {
        return _descriptionTextView;
    }

    CGRect descriptionRect = {{0, 5}, {300, 102}};
    FMTextView *descriptionTextView = [[FMTextView alloc] initWithFrame:descriptionRect];
    descriptionTextView.backgroundColor = [UIColor whiteColor];
    descriptionTextView.placeholder = kItemDefaultDescriptionText;
    descriptionTextView.placeholderTextColor = FMColorWithRed(178, 178, 178);
    descriptionTextView.layer.cornerRadius = 6;
    descriptionTextView.font = FMFont(NO, 15);
    descriptionTextView.delegate = self;
    descriptionTextView.text = (_itemDO.description && [_itemDO.description isNotBlank]) ?
            _itemDO.description : @"";
    _descriptionTextView = descriptionTextView;
    return _descriptionTextView;
}

- (UITextField *)userTextField {
    CGRect userRect = {{10, 0}, {280, 42}};
    UITextField *userTextField = [[UITextField alloc] initWithFrame:userRect];
    userTextField.backgroundColor = [UIColor whiteColor];
    userTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userTextField.placeholder = @"联系人";
    userTextField.font = FMFont(NO, 15);
    userTextField.text = _itemDO.contacts;
    userTextField.delegate = self;
    return userTextField;
}

- (UITextField *)postFeeTextField {
    CGRect rect = {{80, 0}, {210, 42}};
    UITextField *postFeeTextField = [[UITextField alloc] initWithFrame:rect];
    postFeeTextField.backgroundColor = [UIColor clearColor];
    postFeeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    postFeeTextField.textAlignment = NSTextAlignmentRight;
    postFeeTextField.font = FMFont(NO, 15);
    postFeeTextField.keyboardType = UIKeyboardTypeDecimalPad;
    postFeeTextField.text = _itemDO.postPrice ?: @"";
    postFeeTextField.delegate = self;
    return postFeeTextField;
}

- (UILabel *)postFeePromptLabel {
    CGRect rect = {{80, 0}, {210, 42}};
    UILabel *postFeeLabel = [[UILabel alloc] initWithFrame:rect];
    postFeeLabel.backgroundColor = [UIColor clearColor];
    postFeeLabel.textAlignment = NSTextAlignmentRight;
    postFeeLabel.textColor = FMColorWithRed(200, 200, 200);
    postFeeLabel.font = FMFont(NO, 15);
    postFeeLabel.text = @"无需物流";
    postFeeLabel.hidden = YES;
    return postFeeLabel;
}

- (UITextField *)phoneTextField {
    CGRect phoneRect = {{10, 0}, {280, 42}};
    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:phoneRect];
    phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneTextField.placeholder = @"联系电话";
    phoneTextField.font = FMFont(NO, 15);
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextField.text = _itemDO.phone;
    phoneTextField.delegate = self;
    return phoneTextField;
}

- (UIView *)tableFooterView {
    CGRect footerRect = {{0, 0}, {FM_SCREEN_WIDTH, 10}};
    return [[UIView alloc] initWithFrame:footerRect];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        if (IS_IPHONE_5) {
            return 130;
        }
        return 114;
    }

    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor whiteColor];

    NSUInteger section = (NSUInteger) indexPath.section;
    NSUInteger row = (NSUInteger) indexPath.row;

    if (section == 0) {
        if (row == 0) {
            FMBaseTableViewCell *categoryCell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                           reuseIdentifier:@"categoryCell"];
            categoryCell.textLabel.text = @"类目";
            categoryCell.backgroundColor = [UIColor whiteColor];
            categoryCell.textLabel.font = FMFont(NO, 15.f);
            categoryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            categoryCell.selectionStyle = UITableViewCellSelectionStyleNone;
            categoryCell.textLabel.textColor = FMColorWithRed(74, 77, 80);
            categoryCell.detailTextLabel.text = _itemDO.categoryName;
            categoryCell.detailTextLabel.textColor = FMColorWithRed(200, 200, 200);
            categoryCell.detailTextLabel.font = FMFont(NO, 15);
            return categoryCell;
        } else if (row == 1) {
            FMBaseTableViewCell *stuffStatusCell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                              reuseIdentifier:@"stuffStatusCell"];
            stuffStatusCell.textLabel.text = @"使用情况";
            stuffStatusCell.selectionStyle = UITableViewCellSelectionStyleNone;
            stuffStatusCell.backgroundColor = [UIColor whiteColor];
            stuffStatusCell.textLabel.font = FMFont(NO, 15.f);
            stuffStatusCell.textLabel.textColor = FMColorWithRed(74, 77, 80);
            stuffStatusCell.detailTextLabel.textColor = FMColorWithRed(200, 200, 200);
            stuffStatusCell.detailTextLabel.font = FMFont(NO, 15);
            stuffStatusCell.detailTextLabel.text = [_itemDO getStuffStatusString];
            return stuffStatusCell;
        } else if (row == 2) {
            FMBaseTableViewCell *offlineCell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                          reuseIdentifier:@"offlineCell"];

            offlineCell.textLabel.text = @"交易方式";
            offlineCell.selectionStyle = UITableViewCellSelectionStyleNone;
            offlineCell.backgroundColor = [UIColor whiteColor];
            offlineCell.textLabel.font = FMFont(NO, 15.f);
            offlineCell.textLabel.textColor = FMColorWithRed(74, 77, 80);
            offlineCell.detailTextLabel.textColor = FMColorWithRed(200, 200, 200);
            offlineCell.detailTextLabel.font = FMFont(NO, 15);
            offlineCell.detailTextLabel.text = [_itemDO getTradeTypeString];
            return offlineCell;
        } else if (row == 3) {
            UITableViewCell *postFeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                  reuseIdentifier:@"stuffStatusCell"];
            postFeeCell.backgroundColor = [UIColor whiteColor];
            postFeeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            postFeeCell.textLabel.text = @"运费(￥)";
            postFeeCell.textLabel.font = FMFont(NO, 15.f);
            postFeeCell.textLabel.textColor = FMColorWithRed(74, 77, 80);
            [postFeeCell.contentView addSubview:_postFeeTextField];
            [postFeeCell.contentView addSubview:_postFeePromptLabel];
            if (_itemDO.offline == FMItemTradeTypeF2F) {
                _postFeeTextField.hidden = YES;
                _postFeePromptLabel.hidden = NO;
            } else {
                _postFeeTextField.hidden = NO;
                _postFeePromptLabel.hidden = YES;
            }
            return postFeeCell;
        } else {
            FMBaseTableViewCell *locationCell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                           reuseIdentifier:@"locationCell"];
            locationCell.textLabel.text = @"所在地";
            locationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            locationCell.textLabel.font = FMFont(NO, 15.f);
            locationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            locationCell.textLabel.textColor = FMColorWithRed(74, 77, 80);
            locationCell.backgroundColor = [UIColor redColor];
            locationCell.detailTextLabel.text = [_itemDO getLocationText];
            locationCell.detailTextLabel.textColor = FMColorWithRed(200, 200, 200);
            locationCell.detailTextLabel.font = FMFont(NO, 15);
            return locationCell;
        }
    }

    if (section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:_userTextField];
        return cell;
    }

    if (section == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:_phoneTextField];
        return cell;
    }

    if (section == 3) {
        [cell.contentView addSubview:[self descriptionTextView]];
        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSUInteger section = (NSUInteger) indexPath.section;
    NSUInteger row = (NSUInteger) indexPath.row;

    if (section == 0) {
        [FMCommon hideKeyboard];
        [self hideAllPickerView];

        if (row == 0) {
            TBMBGlobalSendNotificationForSEL(@selector($$postCategoryNotification:));
            return;
        }

        if (row == 1) {
            [self showStuffStatusPickerView];
            return;
        }

        if (row == 2) {
            [self showOfflinePickerView];
            return;
        }

        if (row == 4) {
            TBMBGlobalSendNotificationForSEL(@selector($$postLocationNotification:));
            return;
        }
        return;
    }
}

- (void)hideAllPickerView {
    [_offlinePickerView hide];
    [_staffStatusPickerView hide];
}

- (void)showOfflinePickerView {
    NSInteger selectedRow = 0;
    if (_itemDO.offline == FMItemTradeTypeAnyway) {
        selectedRow = 0;
    } else if (_itemDO.offline == FMItemTradeTypeOnline) {
        selectedRow = 1;
    } else if (_itemDO.offline == FMItemTradeTypeF2F) {
        selectedRow = 2;
    }
    [_offlinePickerView.pickerView selectRow:selectedRow inComponent:0 animated:NO];
    [_offlinePickerView show];
}

- (void)showStuffStatusPickerView {
    NSInteger selectedRow = 1;
    if (_itemDO.stuffStatus == 10) {
        selectedRow = 0;
    } else if (_itemDO.stuffStatus == 9) {
        selectedRow = 1;
    }

    [_staffStatusPickerView.pickerView selectRow:selectedRow inComponent:0 animated:NO];
    [_staffStatusPickerView show];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    _itemDO.isEditItemChanged = YES;
    UITextField *textField = notification.object;
    if (textField == _userTextField) {
        NSString *usernameText = _userTextField.text;
        if ([usernameText length] > kPostUsernameMaxLength) {
            usernameText = [usernameText substringToIndex:kPostUsernameMaxLength];
            _userTextField.text = usernameText;
        }
        _itemDO.contacts = usernameText;
        return;
    }

    if (textField == _phoneTextField) {
        [self phoneTextDidChanged];
        return;
    }

    if (textField == _postFeeTextField) {
        [self postFeeDidChanged];
        return;
    }
}

- (void)phoneTextDidChanged {
    NSString *phoneText = _phoneTextField.text;
    if ((phoneText == nil) || [phoneText isBlank]) {
        _phoneTextField.text = @"";
        _itemDO.phone = @"";
        return;
    }

    if (![FMCommon isDigest:phoneText]) {
        [FMCommon alert:@"" message:@"手机号码应该是数字"];
        phoneText = [phoneText length] > 1 ? ([phoneText substringToIndex:[phoneText length] - 1]) : @"";
        _phoneTextField.text = phoneText;
    }

    if ([phoneText length] > 11) {
        [FMCommon alert:@"" message:@"手机号码必须是11位数字"];
        phoneText = [phoneText length] > 1 ? ([phoneText substringToIndex:[phoneText length] - 1]) : @"";
        _phoneTextField.text = phoneText;
    }

    _itemDO.phone = phoneText;
}

- (void)postFeeDidChanged {
    NSString *postFeeText = _postFeeTextField.text;

    if ((postFeeText == nil) || postFeeText.length == 0) {
        _postFeeTextField.text = @"";
        _itemDO.postPrice = @"";
        return;
    }

    double value = [postFeeText doubleValue];
    if (![FMCommon isPrice:postFeeText] || value >= kPostPostFeeMaxValue) {
        NSString *alertString = value >= kPostPostFeeMaxValue ? [NSString stringWithFormat:@"宝贝运费不能大于%d元", kPostPostFeeMaxValue] : @"请输入正确的邮费";
        [FMCommon alert:@"" message:alertString];
        postFeeText = [postFeeText length] > 1 ? ([postFeeText substringToIndex:[postFeeText length] - 1]) : @"";
        _postFeeTextField.text = postFeeText;
    }

    _itemDO.postPrice = postFeeText;
}

- (void)$$postKeyboardWillShowNotification:(id <TBMBNotification>)notification
                                    height:(NSNumber *)height {
    float h = [height floatValue];
    CGRect frame = self.frame;
    frame.size.height = FM_SCREEN_HEIGHT - h;
    self.frame = frame;
}

- (void)$$postKeyboardWillHideNotification:(id <TBMBNotification>)notification {
    CGRect frame = self.frame;
    frame.size.height = FM_SCREEN_HEIGHT - kTabBarHeight;
    self.frame = frame;
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -30.f) {
        [self.textIndicationView setState:FMPostIndicationStateNormal];
        return;
    }
    [self.textIndicationView setState:FMPostIndicationStateDone];
    return;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -30.f) {
        [self hideAllPickerView];
        TBMBGlobalSendNotificationForSEL(@selector($$postOptionalViewEndDraggingNotification:));
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self hideAllPickerView];

    if (textField == _userTextField) {
        [self setContentOffset:CGPointMake(0, 160) animated:YES];
        return YES;
    }

    if (textField == _phoneTextField) {
        [self setContentOffset:CGPointMake(0, 200) animated:YES];
        return YES;
    }

    return YES;
}

#pragma mark - text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self hideAllPickerView];

    [self setContentOffset:CGPointMake(0, 240) animated:YES];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _itemDO.isEditItemChanged = YES;
    _itemDO.description = textView.text;
    _itemDO.isDescriptionChanged = YES;
}

- (void)releasePickerView:(FMPostPickerView *)pickerView {
    [pickerView removeFromSuperview];
    pickerView.delegate = nil;
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
    [self releasePickerView:_offlinePickerView];
    [self releasePickerView:_staffStatusPickerView];
    [[TBMBGlobalFacade instance] unsubscribeNotification:self];
}

#pragma mark - picker view delete
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == _offlinePickerView.pickerView) {
        return 1;
    }

    if (pickerView == _staffStatusPickerView.pickerView) {
        return 1;
    }

    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _offlinePickerView.pickerView) {
        return 3;
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _offlinePickerView.pickerView) {
        NSArray *offlineTexts = @[@"在线/同城", @"在线交易", @"同城交易"];
        return [offlineTexts objectAtIndex:(NSUInteger) row];
    }

    if (pickerView == _staffStatusPickerView.pickerView) {
        NSArray *staffStatusTexts = @[@"全新", @"非全新"];
        return [staffStatusTexts objectAtIndex:(NSUInteger) row];
    }

    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    _itemDO.isEditItemChanged = YES;
    if (pickerView == _offlinePickerView.pickerView) {
        BOOL enable = YES;
        if (row == 0) {
            _itemDO.offline = FMItemTradeTypeAnyway;
        } else if (row == 1) {
            _itemDO.offline = FMItemTradeTypeOnline;
        } else if (row == 2) {
            _itemDO.offline = FMItemTradeTypeF2F;
            enable = NO;
        }
        [self setPostFeeCellEnable:enable];
        return;
    }

    if (pickerView == _staffStatusPickerView.pickerView) {
        if (row == 0) {
            _itemDO.stuffStatus = 10;
        } else if (row == 1) {
            _itemDO.stuffStatus = 9;
        }
        return;
    }
}

- (void)setPostFeeCellEnable:(BOOL)enable {
    if (enable) {
        _postFeeTextField.hidden = NO;
        _postFeePromptLabel.hidden = YES;
        return;
    }
    _postFeeTextField.hidden = YES;
    _postFeePromptLabel.hidden = NO;
    return;
}

@end