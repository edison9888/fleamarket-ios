//
// Created by henson on 11/1/12.
// 

#import <Foundation/Foundation.h>

typedef enum {
    FMSystemMessageSystem = 1,
    FMSystemMessageActivity
} FMSystemMessageType;

@interface FMSystemMessageContent : NSObject {
    NSString *_title;
    NSString *_desc;
    NSString *_pictureURL;  //图片URL，可以没有
    NSString *_actionURL; //点击后跳转的URL
    FMSystemMessageType _type; //类型(系统消息、官方活动)
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *pictureURL;
@property(nonatomic, copy) NSString *actionURL;
@property(nonatomic) FMSystemMessageType type;


@end