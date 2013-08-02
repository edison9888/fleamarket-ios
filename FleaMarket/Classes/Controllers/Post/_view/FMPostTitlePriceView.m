// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <MBMvc/TBMBUtil.h>
#import "FMPostTitlePriceView.h"
#import "FMItemDO.h"
#import "TBMBDefaultNotification.h"

#define kPostItemPriceMaxValue      (99999999.99)
#define kPostItemTitleMaxLength     (30)

@implementation FMPostTitlePriceView {

@private
    UITextField *_titleTextField;
    UITextField *_priceTextField;
    UITextField *_originalPriceTextField;
    FMItemDO *_itemDO;
}

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO {
    self = [super initWithFrame:frame];
    if (self) {
        _itemDO = itemDO;
        TBMBAutoBindingKeyPath(self);

        CGRect titleRect = {{10, 0}, {300, 44}};
        UITextField *titleTextField = [[UITextField alloc] initWithFrame:titleRect];
        titleTextField.backgroundColor = [UIColor whiteColor];
        titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        titleTextField.layer.borderWidth = 1;
        titleTextField.layer.borderColor = [FMColorWithRed(213, 213, 213) CGColor];
        titleTextField.layer.cornerRadius = 6;
        titleTextField.placeholder = @"宝贝标题";
        titleTextField.delegate = self;
        titleTextField.returnKeyType = UIReturnKeyDone;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        titleTextField.leftView = paddingView;
        titleTextField.leftViewMode = UITextFieldViewModeAlways;

        UIButton *barScanButton = [self barScanButton];
        barScanButton.frame = CGRectMake(0, 0, 44, 44);
        titleTextField.rightView = barScanButton;
        titleTextField.rightViewMode = UITextFieldViewModeAlways;

        [self addSubview:titleTextField];
        _titleTextField = titleTextField;
        _titleTextField.text = _itemDO.title ?: @"";

        CGRect priceContainerRect = {{10, titleRect.origin.y + titleRect.size.height + 10}, {FM_SCREEN_WIDTH - 20, 44}};
        UIView *priceContainerView = [[UIView alloc] initWithFrame:priceContainerRect];
        priceContainerView.backgroundColor = [UIColor whiteColor];
        priceContainerView.layer.borderWidth = 1;
        priceContainerView.layer.borderColor = [FMColorWithRed(213, 213, 213) CGColor];
        priceContainerView.layer.cornerRadius = 6;

        UILabel *pricePlaceHolder = [self RMBPlaceHolderView];
        pricePlaceHolder.text = @"转让价(￥)  ";
        pricePlaceHolder.frame = CGRectMake(0, 0, 65, 44);

        CGRect priceRect = {{0, 0}, {149, 44}};
        UITextField *priceTextField = [[UITextField alloc] initWithFrame:priceRect];
        priceTextField.backgroundColor = [UIColor clearColor];
        priceTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        priceTextField.leftView = pricePlaceHolder;
        priceTextField.leftViewMode = UITextFieldViewModeAlways;
        priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
        priceTextField.delegate = self;
        [priceContainerView addSubview:priceTextField];
        _priceTextField = priceTextField;
        _priceTextField.text = _itemDO.price ?: @"";

        UIView *middleLineView = [[UIView alloc] initWithFrame:CGRectMake(149, 0, 1, 44)];
        middleLineView.backgroundColor = FMColorWithRed(213, 213, 213);
        [priceContainerView addSubview:middleLineView];

        UILabel *originalPricePlaceHolder = [self RMBPlaceHolderView];
        originalPricePlaceHolder.text = @"原价(￥)  ";
        originalPricePlaceHolder.frame = CGRectMake(0, 0, 53, 44);

        CGRect originalPriceRect = {{priceRect.origin.x + priceRect.size.width + 1, 0}, {149, 44}};
        UITextField *originalPriceTextField = [[UITextField alloc] initWithFrame:originalPriceRect];
        originalPriceTextField.backgroundColor = [UIColor clearColor];
        originalPriceTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        originalPriceTextField.delegate = self;
        originalPriceTextField.keyboardType = UIKeyboardTypeDecimalPad;
        originalPriceTextField.leftView = originalPricePlaceHolder;
        originalPriceTextField.leftViewMode = UITextFieldViewModeAlways;
        [priceContainerView addSubview:originalPriceTextField];
        _originalPriceTextField = originalPriceTextField;
        _originalPriceTextField.text = _itemDO.originalPrice;

        [self addSubview:priceContainerView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_titleTextField];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_priceTextField];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:_originalPriceTextField];
    }

    return self;
}

- (UIButton *)barScanButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"post_barscan_icon.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(barScan) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)RMBPlaceHolderView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    label.textColor = FMColorWithRed(178, 178, 178);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
    label.font = FMFont(YES, 10.f);
    return label;
}

- (void)refreshView {
    _titleTextField.text = _itemDO.title;
    _priceTextField.text = _itemDO.price;
    _originalPriceTextField.text = _itemDO.originalPrice;

    if (_itemDO.taoBaoTradeOrder || _itemDO.resell) {
        _originalPriceTextField.textColor = [UIColor lightGrayColor];
        _originalPriceTextField.enabled = NO;
    }
}

- (void)setTitleText:(NSString *)text {
    _titleTextField.text = text;
}

- (void)barScan {
    [_titleTextField resignFirstResponder];
    TBMBGlobalSendNotificationForSEL(@selector($$postBarCodeScanNotification:));
}

- (void)textFieldDidChange:(NSNotification *)notification {
    _itemDO.isEditItemChanged = YES;

    UITextField *textField = notification.object;
    if (textField == _titleTextField) {
        [self titleTextFieldChanged];
        return;
    }

    if (textField == _priceTextField) {
        [self priceTextFieldChanged];
        return;
    }

    if (textField == _originalPriceTextField) {
        [self originalPriceTextFieldChanged];
        return;
    }
}

- (void)titleTextFieldChanged {
    _itemDO.title = _titleTextField.text;
    return;
}

- (void)priceTextFieldChanged {
    NSString *priceText = _priceTextField.text;
    double value = [priceText doubleValue];
    if (![FMCommon isPrice:priceText] || value > kPostItemPriceMaxValue) {
        NSString *alertString = value > kPostItemPriceMaxValue ? @"亲，宝贝价格必须在0元与1亿元之间" : @"亲，请输入正确的价格";
        [FMCommon alert:@"" message:alertString];
        priceText = [priceText length] > 1 ? ([priceText substringToIndex:[priceText length] - 1]) : @"";
        _priceTextField.text = priceText;
    }
    _itemDO.price = priceText;
    return;
}

- (void)originalPriceTextFieldChanged {
    NSString *originalPriceText = _originalPriceTextField.text;
    double value = [originalPriceText doubleValue];
    if (![FMCommon isPrice:originalPriceText] || value > kPostItemPriceMaxValue) {
        NSString *alertString = nil;
        alertString = value > kPostItemPriceMaxValue ? @"亲，宝贝原价必须在0元与1亿元之间" : @"亲，请输入正确的原价";
        [FMCommon alert:@"" message:alertString];
        originalPriceText = [originalPriceText length] > 1 ? ([originalPriceText substringToIndex:[originalPriceText length] - 1]) : @"";
        _originalPriceTextField.text = originalPriceText;
    }
    _itemDO.originalPrice = originalPriceText;
    return;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _originalPriceTextField) {
        return;
    }
    TBMBDefaultNotification *notification = [TBMBDefaultNotification
            objectWithSEL:@selector($$postGuessCategory:)
                     body:nil];
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            _priceTextField.text, kFMPostPriceTextField,
            _titleTextField.text, kFMPostTitleTextField,
            nil];
    TBMBGlobalSendTBMBNotification(notification);
}

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }

    if (textField == _titleTextField) {
        if (([FMCommon textLength:textField.text] + [FMCommon textLength:string]) > kPostItemTitleMaxLength) {
            return NO;
        }
    }

    return YES;
}

@end