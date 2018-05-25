//
//  ChatManager.h
//  Lemeng
//
//  Created by Kevin Lai on 14-8-26.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOConversation.h"
#import "ONOBaseMessage.h"

@interface ONODB : NSObject

+ (ONOConversation *)fetchConversation:(NSString *)userId;
+ (ONOConversation *)fetchConversation:(NSString *)userId andMessageType:(NSInteger )messageType;
+ (NSArray<ONOConversation *> *)fetchConversations;

+ (void)insertConversation:(ONOConversation *)conversation;
+ (void)updateConversation:(ONOConversation *)conversation;
+ (void)deleteConversation:(NSString *)userId;

+(void)insertUser:(ONOUser *)user;
+(void)updateUser:(ONOUser *)user;
+(ONOUser *)fetchUser:(NSString *)userId;

+ (ONOBaseMessage*)fetchMessage:(NSString *)msgId;
+ (NSArray*)fetchMessages:(NSString *)userId offset:(NSString *)offset limit:(int)limit;
+ (void)insertMessage:(ONOBaseMessage*)message to:(NSString *)userId;
+ (void)updateMessage:(ONOBaseMessage*)message fromOldId:(NSString *)oldMessageId;
+ (void)updateMessageError:(BOOL)error msgId:(NSString *)msgId;
+ (void)deleteMessage:(NSString *)userId msgId:(NSString *)msgId;


@end
