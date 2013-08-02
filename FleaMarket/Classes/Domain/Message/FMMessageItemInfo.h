//
// Created by henson on 11/12/12.
// 

#import <Foundation/Foundation.h>


@interface FMMessageItemInfo : NSObject {
    NSString *_itemId;
    NSString *_itemTitle;
    NSString *_itemPictureURL;
}
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *itemTitle;
@property(nonatomic, copy) NSString *itemPictureURL;

@end