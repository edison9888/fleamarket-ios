//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-5-22 下午4:59.
//


#import <Foundation/Foundation.h>

extern inline NSDictionary *TBIUGetProperty(Class clazz);

extern inline void TBIUBeanCopy(NSObject *src, NSObject *dest);

@interface NSObject (TBIU_BeanCopy)

- (void)cloneToBean:(NSObject *)dest;

- (id)cloneToNewBean:(Class)clazz;

- (void)fromBean:(NSObject *)src;
@end