//
//  FMCameraFocusLayer.m
//  FleaMarket
//
//  Created by Henson on 11/20/12.
//  Copyright (c) 2012 Taobao, inc. All rights reserved.
//

#import "FMCameraFocusLayer.h"

@implementation FMCameraFocusLayer

- (void)drawInContext:(CGContextRef)ctx {
#define OFFSET 4.f
    CGRect t = self.bounds;
    t.origin.x += OFFSET;
    t.origin.y += OFFSET;
    t.size.width -= OFFSET * 2;
    t.size.height -= OFFSET * 2;

    //CGColorRef c1 = [UIColor colorWithRed:0.525 green:0.65 blue:0.737 alpha:1.f].CGColor;
    CGColorRef c1 = [UIColor greenColor].CGColor;
    CGColorRef c2 = [UIColor whiteColor].CGColor;

    CGFloat V = t.size.width / 15;

    for (int i = 0; i < 3; i++) {
        CGMutablePathRef path = CGPathCreateMutable();

        CGFloat w = t.size.width;
        CGFloat w2 = t.size.width / 2;
        CGFloat h = t.size.height;
        CGFloat h2 = t.size.height / 2;

        CGPathMoveToPoint(path, NULL, t.origin.x, t.origin.y);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y + V);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y);

        CGPathAddLineToPoint(path, NULL, t.origin.x + w, t.origin.y);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w, t.origin.y + h2);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w - V, t.origin.y + h2);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w, t.origin.y + h2);

        CGPathAddLineToPoint(path, NULL, t.origin.x + w, t.origin.y + h);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y + h);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y + h - V);
        CGPathAddLineToPoint(path, NULL, t.origin.x + w2, t.origin.y + h);

        CGPathAddLineToPoint(path, NULL, t.origin.x, t.origin.y + h);
        CGPathAddLineToPoint(path, NULL, t.origin.x, t.origin.y + h2);
        CGPathAddLineToPoint(path, NULL, t.origin.x + V, t.origin.y + h2);
        CGPathAddLineToPoint(path, NULL, t.origin.x, t.origin.y + h2);

        CGPathCloseSubpath(path);

        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 1.2f);
        CGContextSetStrokeColorWithColor(ctx, i % 2 ? c2 : c1);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);

        CGPathRelease(path);

        t.origin.x += 1.f;
        t.origin.y += 1.f;
        t.size.width -= 2.f;
        t.size.height -= 2.f;
    }
}

@end
