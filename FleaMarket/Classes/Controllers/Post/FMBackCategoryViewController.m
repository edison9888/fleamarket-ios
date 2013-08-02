// 
// Created by henson on 7/12/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBProgressHUD/MBProgressHUD.h>
#import "FMBackCategoryViewController.h"
#import "FMCommon.h"
#import "FMCategoryService.h"
#import "FMCategory.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@implementation FMBackCategoryViewController {
    NSUInteger _currentLevel;
    NSMutableDictionary *_categoriesLevel;
    NSMutableArray *_categoriesName;
    UITableView *_tableView;
    NSMutableArray *_returnCategories;
    NSMutableArray *_initCategories;

    void (^_categoryDidSelectBlock)(NSArray *);
}

- (id)init {
    self = [super init];
    if (self) {
        _currentLevel = 0;
        _categoriesLevel = [[NSMutableDictionary alloc] initWithCapacity:3];
        _categoriesName = [[NSMutableArray alloc] initWithCapacity:3];
        _returnCategories = [[NSMutableArray alloc] initWithCapacity:3];
        [_categoriesName addObject:@"类目"];
    }

    return self;
}

- (id)initWithCategories:(NSArray *)categories {
    self = [self init];
    if (self) {
        _initCategories = [NSMutableArray arrayWithArray:categories];
    }
    return self;
}

- (void)initNavigationBar {
    [self setTitle:[_categoriesName objectAtIndex:_currentLevel]];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    _tableView = [[UITableView alloc]
            initWithFrame:CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight)
                    style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _tableView.backgroundView = nil;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestCategory:@"" level:_currentLevel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)dealloc {
    FMLog(@"%@ dealloc", [self description]);
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}


- (void)requestCategory:(NSString *)catId level:(NSUInteger)level {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中";

    [FMCategoryService getStdCategoryList:catId
                                  success:^(NSArray *cats) {
                                      NSMutableArray *categories;
                                      if ((categories = [_categoriesLevel objectForKey:[NSNumber
                                              numberWithUnsignedInteger:level]]) == nil) {
                                          categories = [[NSMutableArray alloc]
                                                  initWithCapacity:19];
                                          [_categoriesLevel setObject:categories
                                                               forKey:[NSNumber numberWithUnsignedInteger:level]];
                                      }
                                      [categories removeAllObjects];
                                      [categories addObjectsFromArray:cats];
                                      [_tableView reloadData];
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  }
                                   failed:^(NSString *error) {
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       if (error != nil && ![error isEqual: @""]) {
                                           [FMCommon showToast:self.view text:error];
                                       }
                                   }];

}

- (void)setCategoryDidSelect:(void (^)(NSArray *))block {
    _categoryDidSelectBlock = block;
}

#pragma - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];
    return [categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];
    static NSString *cellIdentifier = @"CategoryCell";
    FMBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.font = FMFont(NO, 15.f);
    cell.textLabel.textColor = FMColorWithRed(74, 77, 80);
    cell.backgroundColor = [UIColor whiteColor];

    FMCategory *category = [categories objectAtIndex:(NSUInteger) indexPath.row];
    if (_initCategories && _currentLevel < _initCategories.count) {
        FMCategory *initCategory = [_initCategories objectAtIndex:_currentLevel];
        if ([initCategory.id intValue] == [category.id intValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else  {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.textLabel.text = category.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];
    FMCategory *category = [categories objectAtIndex:(NSUInteger) indexPath.row];
    if (category.leaf) {
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
        [_returnCategories addObject:category];
        if (_categoryDidSelectBlock) {
            _categoryDidSelectBlock(_returnCategories);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _currentLevel++;
        [_categoriesName addObject:category.name?:@""];
        [_returnCategories addObject:category];
        [self setTitle:category.name?:@""];
        [self requestCategory:category.id level:_currentLevel];
    }
}

- (void)leftAction:(id)sender {
    if (_currentLevel == 0) {
        [super leftAction:sender];
    } else {
        _currentLevel--;
        [_categoriesName removeLastObject];
        [self setTitle:[_categoriesName objectAtIndex:_currentLevel]];
        [_tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end