//
//  IMAPI.h
//  Dida
//
//  Created by Kevin Lai on 15/5/9.
//  Copyright (c) 2018年 Xiamen ONO technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOMessage.h"
#import "ONOBaseMessage.h"
#import "ONOConversation.h"

@protocol ONOReceiveMessageDelegate <NSObject>
- (void)onReceived:(ONOBaseMessage *)message;
@end


@interface ONOIMClient : NSObject

+ (ONOIMClient *)sharedClient;

@property (nonatomic, weak) id<ONOReceiveMessageDelegate> receiveMessageDelegate;

/**
 *  设置聊天服务器参数
 *
 *  @param host    帐号
 *  @param port    端口号
 */
- (void)setupWithHost:(NSString*)host port:(int)port;


/**
 *  登录
 *
 *  @param token      令牌 (在后台绑定的登录token)
 */
- (void)loginWithToken:(NSString *)token onSuccess:(void(^)(ONOUser *user))successBlock onError:(void(^)(int errorCode, NSString *errorMsg))errorBlock;

/**
 *  发送消息
 *
 *  @param message   要发送的消息
 *  @param userId    目标用户ID
 */

- (void)sendMessage:(ONOBaseMessage *)message to:(NSString *)userId onSuccess:(void (^)(NSString *messageId))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock;

/**
 *  获取会话列表
 */
- (NSArray <ONOConversation *>*)getConversationList;

/**
 *  获取单个会话信息
 *  @param userId    目标用户ID
 */
- (ONOConversation *)getConversation:(NSString *)userId;


- (ONOBaseMessage *)createMessageByType:(int)type;

@end

