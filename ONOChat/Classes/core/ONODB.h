//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOConversation.h"
#import "ONOMessage.h"

@interface ONODB : NSObject

+ (ONOConversation *)fetchConversation:(NSString *)targetId;
+ (ONOConversation *)fetchConversation:(NSString *)targetId withConversationType:(NSInteger)conversationType;
+ (NSArray<ONOConversation *> *)fetchConversations;

+ (void)insertConversation:(ONOConversation *)conversation;
+ (void)updateConversation:(ONOConversation *)conversation;
+ (void)updateConversation:(NSString *)targetId toNewMessageId:(NSString *)messageId;
+ (void)deleteConversation:(NSString *)targetId;

+(void)insertUser:(ONOUser *)user;
+(void)updateUser:(ONOUser *)user;
+(void)insertOrUpdateUser:(ONOUser *)user;
+(ONOUser *)fetchUser:(NSString *)userId;

+(void)insertOrUpdateFriend:(NSString *)friendId;
+ (void)deleteFriend:(NSString *)friendId;
+ (nullable NSArray<ONOUser *> *)getFriends;

+ (ONOMessage*)fetchMessage:(NSString *)msgId;
+ (NSArray*)fetchMessages:(NSString *)userId offset:(NSString *)offset limit:(int)limit;
+ (void)insertMessage:(ONOMessage*)message;
+ (void)markMessageSend:(NSString *)newMessgeId fromOldId:(NSString *)oldMessageId;
+ (void)markMessageError:(BOOL)error msgId:(NSString *)msgId;
+ (void)deleteMessage:(NSString *)userId msgId:(NSString *)msgId;

+ (int)totalUnreadCount;

+ (void)clearConversationUnread:(NSString *)targetId;

@end
