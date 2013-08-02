//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:28.
//

#import "FMFrontCategoryViewController.h"
#import "FMSearchParameter.h"
#import "FMCategory.h"
#import "FMCommon.h"
#import "NSString+Helper.h"
#import "ClientApiBaseReturn.h"
#import "RemoteEvent.h"
#import "FMCategoryService.h"
#import "FMListViewController.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMFrontCategoryViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FMFrontCategoryViewController {
    UITableView *_categoryTableView;
    FMSearchParameter *_searchParameter;
    NSArray *_initCategories;  //类目层级

    NSMutableArray *_categories;
    NSUInteger _currentLevel;
    NSMutableDictionary *_categoriesLevel;


    void (^_didSelectAction)(NSArray *);

    FMFrontCategoryViewType _categoryViewType;
}

- (void)initNavigationBar {
    [self setTitle:@"类目筛选"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (id)initWithType:(FMFrontCategoryViewType)viewType {
    if (self = [self init]) {
        _categoryViewType = viewType;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _currentLevel = 0;
        _categoriesLevel = [[NSMutableDictionary alloc] initWithCapacity:3];
        _categories = [[NSMutableArray alloc] init];
        [_categories addObject:[self _rootCategory]];
    }

    return self;
}

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter {
    self = [self init];
    if (self) {
        _searchParameter = searchParameter;
        _initCategories = [NSArray arrayWithArray:searchParameter._category$FMCategory];
    }

    return self;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableViewRect = {{0, 44}, FM_SCREEN_WIDTH, self.view.frame.size.height - 44};
    _categoryTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    _categoryTableView.delegate = self;
    _categoryTableView.dataSource = self;
    _categoryTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _categoryTableView.backgroundView = nil;
    _categoryTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    [self.view addSubview:_categoryTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestCategory:@"" level:_currentLevel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_categoryViewType == FMFrontCategoryViewTypeSearch && _categories.count >= 2) {
        [_categories removeObjectAtIndex:1];
    }
}

- (void)leftAction:(id)sender {
    if (_categories.count > _currentLevel) {
        [_categories removeObjectAtIndex:_currentLevel];
    }
    if (_currentLevel == 0) {
        [super leftAction:sender];
    } else {
        _currentLevel--;
        [_categoryTableView reloadData];
    }
}

- (void)setDidSelectAction:(void (^)(NSArray *categories))block {
    _didSelectAction = block;
}

- (FMCategory *)_rootCategory {
    __autoreleasing FMCategory *rootCategory = [[FMCategory alloc] init];
    rootCategory.name = @"";
    rootCategory.id = KCategoryRootID;
    rootCategory.leaf = NO;
    return rootCategory;
}

- (void)requestCategory:(NSString *)catId level:(NSUInteger)level {
    [FMCategoryService getCategoryList:catId
                               success:(EventListener) ^(SuccessRemoteEvent *event) {
                                   ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
                                   NSMutableArray *categories;
                                   if ((categories = [_categoriesLevel objectForKey:[NSNumber
                                           numberWithUnsignedInteger:level]]) == nil) {
                                       categories = [[NSMutableArray alloc]
                                                                     initWithCapacity:19];
                                       [_categoriesLevel setObject:categories
                                                            forKey:[NSNumber numberWithUnsignedInteger:level]];
                                   }
                                   [categories removeAllObjects];
                                   [categories addObjectsFromArray:((FMCategoryList *) clientApiBaseReturn.data).items];
                                   [_categoryTableView reloadData];
                               }
                                failed:(EventListener) ^(FailedRemoteEvent *event) {
                                    if (event.context.hasError) {
                                        NSError *error = [event.context.errorMessage objectAtIndex:0];
                                        NSString *errorMessage = error.localizedDescription;
                                        if (errorMessage != nil && ![errorMessage isEqual: @""]) {
                                        }
                                    }
                                }];
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];
    return categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterCategoryTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }

    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];

    FMCategory *cat = _initCategories.count <= _currentLevel ? nil : [_initCategories objectAtIndex:_currentLevel];
    if (indexPath.section == 0) {
        FMCategory *headerCategory = nil;
        if (_categories.count > _currentLevel) {
            headerCategory = [_categories objectAtIndex:_currentLevel];
        }
        if (!headerCategory || [headerCategory.name isBlank]) {
            cell.textLabel.text = @"全部类目";
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"全部%@", headerCategory.name];
            if (cat && [cat.id intValue] == [headerCategory.id intValue]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        return cell;
    }

    FMCategory *category = [categories objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = category.name;
    if (cat && [cat.id intValue] == [category.id intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self deleteRootCategory];
        if (_categoryViewType == FMFrontCategoryViewTypeSearch) {
            [self pushListViewController:_categories];
            return;
        }
        if (_didSelectAction) {
            _didSelectAction(_categories);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    NSArray *categories = [_categoriesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_currentLevel]];
    FMCategory *category = [categories objectAtIndex:(NSUInteger) indexPath.row];
    if (category.leaf) {
        [_categories addObject:category];
        if (_categoryViewType == FMFrontCategoryViewTypeSearch) {
            [self deleteRootCategory];
            [self pushListViewController:_categories];
            return;
        }
        if (_didSelectAction) {
            [self deleteRootCategory];
            _didSelectAction(_categories);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _currentLevel++;
        [_categories addObject:category];
        [self requestCategory:category.id level:_currentLevel];
    }
}

- (void)pushListViewController:(NSArray *)array {
    FMListViewController *listViewController = [[FMListViewController alloc] initWithCategory:array];
    [listViewController setTitle:@"搜索"];
    listViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)deleteRootCategory {
    if (_categories.count > 0) {
        FMCategory *__category = [_categories objectAtIndex:0];
        if ([__category.id isEqualToString:KCategoryRootID])
            [_categories removeObject:__category];
    }
}

@end