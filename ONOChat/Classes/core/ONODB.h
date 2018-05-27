//
//  ChatManager.h
//  Lemeng
//
//  Created by Kevin Lai on 14-8-26.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
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
+ (void)deleteConversation:(NSString *)userId;

+(void)insertUser:(ONOUser *)user;
+(void)updateUser:(ONOUser *)user;
+(ONOUser *)fetchUser:(NSString *)userId;

+ (ONOMessage*)fetchMessage:(NSString *)msgId;
+ (NSArray*)fetchMessages:(NSString *)userId offset:(NSString *)offset limit:(int)limit;
+ (void)insertMessage:(ONOMessage*)message;
+ (void)markMessageSend:(NSString *)newMessgeId fromOldId:(NSString *)oldMessageId;
+ (void)markMessageError:(BOOL)error msgId:(NSString *)msgId;
+ (void)deleteMessage:(NSString *)userId msgId:(NSString *)msgId;


@end
