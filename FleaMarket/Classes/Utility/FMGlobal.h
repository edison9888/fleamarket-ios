//
//  FMGlobal.h
//  FleaMarket
//
//  Created by Henson on 12-10-12.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//
#define kNavigationBarHeight (44)
#define kNavigationBarShadeHeight (3)
#define kTabBarHeight (44)
#define kStatusBarHeight (20)

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define FM_SCREEN_HEIGHT ((float)[[UIScreen mainScreen] bounds].size.height)
#define FM_SCREEN_WIDTH ((float)[[UIScreen mainScreen] bounds].size.width)

#define FMColorWithRedAlpha(RED,GREEN,BLUE,ALPHA)  ([UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:ALPHA])

#define FMColorWithRed(RED,GREEN,BLUE)  FMColorWithRedAlpha(RED,GREEN,BLUE,1.0)

#define FMColorWithRGB0X(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define FMFont(isBold, fontSize)   \
isBold ? [UIFont fontWithName:@"TrebuchetMS-Bold" size:fontSize] : [UIFont fontWithName:@"TrebuchetMS" size:fontSize]

#define FMPlaceholderImage ([[UIImage imageNamed:@"placeholder_image.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)])
