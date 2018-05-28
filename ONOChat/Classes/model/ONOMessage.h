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
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) ONOUser *user;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) BOOL isError;

- (NSInteger)type;
- (NSString *)encode;
- (void)decode:(NSString *)data;

@end
