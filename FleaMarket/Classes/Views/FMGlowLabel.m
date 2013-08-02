//
// Created by yuanxiao on 13-7-18.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMGlowLabel.h"


@implementation FMGlowLabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _redValue = 00.0f;
        _greenValue = 00.0f;
        _blueValue = 00.0f;
        _size = 5.0f;
    }
    return self;
}

- (void)drawTextInRect: (CGRect)rect {
    //定义阴影区域
    CGSize textShadowOffest = CGSizeMake(0, 0);
    //定义RGB颜色值
    float textColorValues[] = {_redValue, _greenValue, _blueValue, 1.0};

    //获取绘制上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //保存上下文状态
    CGContextSaveGState(ctx);

    //为上下文设置阴影
    CGContextSetShadow(ctx, textShadowOffest, _size);
    //设置颜色类型
    CGColorSpaceRef textColorSpace = CGColorSpaceCreateDeviceRGB();
    //根据颜色类型和颜色值创建CGColorRef颜色
    CGColorRef textColor = CGColorCreate(textColorSpace, textColorValues);
    //为上下文阴影设置颜色，阴影颜色，阴影大小
    CGContextSetShadowWithColor(ctx, textShadowOffest, _size, textColor);

    [super drawTextInRect:rect];
    //释放
    CGColorRelease(textColor);
    CGColorSpaceRelease(textColorSpace);

    //重启上下文
    CGContextRestoreGState(ctx);
}


@end