//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOCMessage.h"
#import "ONOMessage.h"
#import "ONOConversation.h"
#import "ONOFriendRequest.h"

@protocol ONOReceiveMessageDelegate <NSObject>
- (void)onReceived:(ONOMessage *)message;
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

- (void)sendMessage:(ONOMessage *)message to:(NSString *)targetId onSuccess:(void (^)(NSString *messageId))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock;

/**
 *  获取会话列表
 */
- (NSArray <ONOConversation *>*)getConversationList;

/**
 *  获取单个会话信息
 *  @param userId    目标用户ID
 */
- (ONOConversation *)getConversation:(NSString *)userId;

/**
 *  获取消息列表
 */
- (NSArray <ONOMessage *>*)getMessageList:(NSString *)targetId offset:(NSString *)offset limit:(int)limit;

/**
 *  获取 好友列表(从本地获取)
 */
- (NSArray <ONOUser *>*)getFriends;

- (int)totalUnreadCount;

- (ONOMessage *)createMessageByType:(int)type;

- (void)userProfile:(NSString *)userId onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;
- (void)userProfile:(NSString *)userId withCache:(BOOL)withCache onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

- (void)userProfiles:(NSArray<NSString*> *)userIds onSuccess:(void (^)(NSArray<ONOUser *> *users))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;



// 好友

/**
 *  好友模糊搜索
 *  @param keyword    搜索关键字
 */
- (void)friendSearchByKeyword:(NSString *)keyword onSuccess:(void (^)(NSArray<ONOUser *> *userArray))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友添加
 *  @param userId       添加好友的id
 *  @param greeting    添加好友的问候语
 */
- (void)friendAddWithUserId:(NSString *)userId andGreeting:(NSString *)greeting onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友添加请求列表
 *  @param limit       条数
 *  @param offset    分页之前的最一条的createdAt
 */
- (void)friendRequestListWithLimit:(int)limit andOffset:(NSString *)offset onSuccess:(void (^)(NSArray<ONOFriendRequest *> *friendRequest))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友添加请求 -> 通过
 *  @param userId       添加请求好友的id
 */
- (void)friendAgreeWithUserId:(NSString *)userId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友添加请求 -> 忽略
 *  @param userId       添加请求好友的id
 */
- (void)friendIgnoreWithUserId:(NSString *)userId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友删除
 *  @param userId       要删除好友的id
 */
- (void)friendDeleteWithUserId:(NSString *)userId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;

/**
 *  好友添加别名(备注名称)
 *  @param userId       好友的id
 *  @param alias       别名
 */
- (void)friendRemarkWithUserId:(NSString *)userId andAlias:(NSString *)alias onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;


- (void)friendListUpdateOnSuccess:(void (^)(NSArray<ONOUser *> *userArray))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock;


@end

