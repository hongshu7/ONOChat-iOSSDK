//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOUser.h"

@interface ONOMessage : NSObject

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) BOOL isError;


/** 1.文本 2.音频 3.图片 4.表情 */
- (NSInteger)type;
- (NSString *)encode;
- (void)decode:(NSString *)data;

@property (nonatomic, strong) ONOUser *user;

@end
