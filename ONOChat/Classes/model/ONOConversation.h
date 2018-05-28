//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
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

@end
