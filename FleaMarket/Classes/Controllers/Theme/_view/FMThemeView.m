//
// Created by yuanxiao on 13-7-19.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import "FMThemeView.h"
#import "FMThemeDO.h"
#import "FMThemeItemCell.h"


@implementation FMThemeView {
@private
    UITableView *_tableView;
    NSUInteger _pageNum;
    FMThemeDOList *_themeDOList;

    //cell animation
    NSInteger _animationMaxHeight;
    NSInteger _needAnimationWithRow;

    void (^_requestBlock)(NSUInteger pageNum);
    void(^_touchItem)(FMThemeDO *themeDO);
}

@synthesize themeDOList = _themeDOList;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITableView *tableView = [[UITableView alloc]
                initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
                        style:UITableViewStylePlain];
        tableView.contentInset = UIEdgeInsetsMake(kFMBaseScrollTitleHeight, 0, 0, 0);
        tableView.backgroundColor = [UIColor clearColor];
        TBMBAutoNilDelegate(UITableView *, tableView, delegate, self);
        TBMBAutoNilDelegate(UITableView *, tableView, dataSource, self);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:tableView];
        _tableView = tableView;

        [self addMoreView:tableView];
        [self addEGORefresh:tableView];

        _pageNum = 1;
    }

    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) indexPath.row;
    FMThemeDO *themeDO = [_themeDOList.items objectAtIndex:row];
    CGFloat height = [FMThemeItemCell cellHeight:themeDO];
    if (_animationMaxHeight < FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight) {
        _animationMaxHeight += height;
        _needAnimationWithRow = indexPath.row;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_themeDOList.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ThemeCell";
    FMThemeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FMThemeItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row <= _needAnimationWithRow) {
        cell.row = indexPath.row;
    } else {
        cell.row = -1;
    }
    NSUInteger row = (NSUInteger) indexPath.row;
    FMThemeDO *themeDO = [_themeDOList.items objectAtIndex:row];
    [cell setThemeDO:themeDO serverTime:_themeDOList.serverTime];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_touchItem) {
        NSUInteger row = (NSUInteger) indexPath.row;
        _touchItem([_themeDOList.items objectAtIndex:row]);
    }
}

- (void)refreshView:(NSUInteger)pageNum {
    [_tableView reloadData];
    [self requestFinish:pageNum > 1];
}

- (void)setRequestBlock:(void(^)(NSUInteger pageNum))block {
    _requestBlock = block;
}

- (void)touchThemeItemView:(void(^)(FMThemeDO *themeDO))block {
    _touchItem = block;
}

- (BOOL)hasNextPage {
    return _themeDOList.nextPage;
}

- (void)requestMore {
    _pageNum++;
    if (_requestBlock) {
        _requestBlock(_pageNum);
    }
}

- (void)refreshData {
    _pageNum = 1;
    if (_requestBlock) {
        _requestBlock(1);
    }
}

@end