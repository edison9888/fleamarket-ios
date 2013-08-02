//
//  huoyanViewController.h
//  huoyan
//
//  Created by Cai Xiaomin on 11/8/12.
//  Copyright (c) 2012 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface huoyanViewController : UIViewController

@property(nonatomic, copy) void (^didFindBarCode)(NSString *);

@property(nonatomic, copy) void (^didFindQRCode)(NSString *);

@end
