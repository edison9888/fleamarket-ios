//
//  FMPostQueueViewController.h
//  FleaMarket
//
//  Created by Henson on 8/29/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMPostQueueViewController : FMBaseViewController <UITableViewDataSource, UITableViewDelegate, FMNeedLoginProtocol> {
    UITableView *_tableView;
    NSMutableArray *_postItems;
}

@end
