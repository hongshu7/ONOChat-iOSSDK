//  Lemeng
//
//  Created by Kevin Lai on 14-8-23.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOUser.h"
#import "ONOMessage.h"

typedef enum _ConversationType {
    ConversationTypePrivate  = 1,
    ConversationTypeGroup,
} ConversationType;

@interface ONOConversation : NSObject

//@property (nonatomic, strong) NSString *belongId;
@property (nonatomic) ConversationType conversationType;
@property (nonatomic) double contactTime;
@property (nonatomic) int unreadCount;

@property (nonatomic, strong) ONOUser *user;
@property (nonatomic, strong) ONOMessage *lastMessage;

@property (nonatomic, assign) BOOL isNew;


@end
