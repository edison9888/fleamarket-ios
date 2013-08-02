//
//  FMPostQueueViewController.m
//  FleaMarket
//
//  Created by Henson on 8/29/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#import "FMPostQueueViewController.h"
#import "FMPostViewController.h"
#import "FMPostQueue.h"
#import "FMItemDO.h"

@interface FMPostQueueViewController ()

@end

@implementation FMPostQueueViewController

- (void)loadView {
    [super loadView];
    [self setTitle:@"发布队列"];
    self.leftBarButton.hidden = NO;
    [self setRightButtonTitle:@"编辑"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, FM_SCREEN_HEIGHT - 20 - 44)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _postItems = [[NSMutableArray alloc] initWithCapacity:5];
}

- (void)rightAction:(id)sender {
    if (_tableView.isEditing) {
        [self setRightButtonTitle:@"编辑"];
        [_tableView setEditing:NO animated:YES];
    } else {
        [_tableView setEditing:YES animated:YES];
        [self setRightButtonTitle:@"完成"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_postItems removeAllObjects];
    NSMutableDictionary *queues = [[FMPostQueue sharedInstance] getPostQueue];
    NSArray *keys = [queues allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    for (NSString *key in sortedKeys) {
        [_postItems addObject:[queues objectForKey:key]];
    }
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)releaseViews {
    [super releaseViews];

    _tableView   = nil;
    _postItems   = nil;
}

- (void)dealloc {
    
}

#pragma mark -For DELETE
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_postItems count] == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deletePostQueue:[_postItems objectAtIndex:(NSUInteger) indexPath.row]];
        [_postItems removeObjectAtIndex:(NSUInteger) indexPath.row];
        if ([_postItems count] == 0) {
            [_tableView reloadData];
        } else {
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)deletePostQueue:(NSDictionary *)postItem {
    if (!postItem) {
        return;
    }
    [[FMPostQueue sharedInstance] deleteItem:[postItem objectForKey:@"item"]];
    [self sendNotificationForSEL:@selector($$postQueueUpdate:)];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_postItems count] > 0) {
        return [_postItems count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_postItems count] == 0) {
        UITableViewCell *noResultCell = [[UITableViewCell alloc] init];
        noResultCell.textLabel.text = @"您暂无发布队列";
        noResultCell.textLabel.textAlignment = (NSTextAlignment) UITextAlignmentCenter;
        return noResultCell;
    }
    
    static NSString *cellIdentifier = @"PostQueueCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = (NSTextAlignment) UITextAlignmentLeft;
        titleLabel.font = FMFont(YES, 15.0f);
        titleLabel.tag = 301;
        titleLabel.textColor = FMColorWithRed(0x22, 0x22, 0x22);
        [cell.contentView addSubview:titleLabel];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 36, 200, 15)];
        timeLabel.textAlignment = (NSTextAlignment) UITextAlignmentLeft;
        timeLabel.font = [UIFont systemFontOfSize:14.f];
        timeLabel.font = FMFont(YES, 15.0f);
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = FMColorWithRed(0x66, 0x66, 0x66);
        timeLabel.tag = 302;
        [cell.contentView addSubview:timeLabel];
    }
    
    FMItemDO *itemDetail = (FMItemDO *)[[_postItems objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"item"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:301];
    titleLabel.text = ([itemDetail.title length] > 0) ? itemDetail.title : @"未命名宝贝";
    
    NSTimeInterval time = [[[_postItems objectAtIndex:(NSUInteger) indexPath.row] valueForKey:@"time"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:302];
    timeLabel.text = [formatter stringFromDate:date];;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];

    if ([_postItems count] < 1) {
        return;
    }

    NSDictionary *itemDict = [_postItems objectAtIndex:(NSUInteger) indexPath.row];
    FMItemDO *itemDO = [itemDict objectForKey:@"item"];
    if (!itemDO) {
        return;
    }

    FMPostViewController *postViewController = [[FMPostViewController alloc] initWithItemDO:itemDO];
    postViewController.isFromQueue = YES;
    UINavigationController *postNavigationController = [[UINavigationController alloc] initWithRootViewController:postViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    [self.navigationController presentViewController:postNavigationController
                                             animated:YES
                                           completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
