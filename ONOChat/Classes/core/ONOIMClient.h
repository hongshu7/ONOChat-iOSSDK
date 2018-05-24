//
//  IMAPI.h
//  Dida
//
//  Created by Kevin Lai on 15/5/9.
//  Copyright (c) 2018年 Xiamen ONO technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOMessage.h"
#import "ONORouteInfo.h"
#import "ONOBaseMessage.h"

//todo:重连机制，客户端保存session id
typedef void (^IMSuccessResponse)(id msg);
typedef void (^IMErrorResponse)(id msg);


@interface ONOIMClient : NSObject

+ (ONOIMClient *)sharedClient;



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
 *  @param success    登录成功回调
 *  @param error      登录失败回调
 */
- (void)loginWithToken:(NSString *)token onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error;



/**
 *  监听消息
 *
 *  @param route      监听指定类型消息
 *  @param response   获得消息回调函数
 *  @return 监听消息的唯一标识码
 */
- (NSInteger)addListenerForRoute:(NSString *)route withCallback:(IMSuccessResponse)response;

/**
 *  移除监听消息
 *
 *  @param listenerId      监听消息的唯一标识码
 */
- (void)removeListenerWithId:(NSInteger)listenerId;


/** 暂时不需要调用的函数 */
@property (nonatomic) NSInteger userId;

- (void)connect;
- (void)disconnect;

- (void)handleConnected:(NSData *)response;
- (void)handleResponse:(ONOMessage *)message;

- (NSString *)getRouteByMsgId:(NSUInteger)msgId;
- (NSString *)getRouteByRouteId:(NSUInteger)routeId;
- (ONORouteInfo *)getRouteInfo:(NSString *)route;


- (void)requestRoute:(NSString *)route withMessage:(GPBMessage *)msg onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error;
- (void)notifyRoute:(NSString *)route withMessage:(GPBMessage *)msg;


- (void)bindClientId:(NSString *)clientId;
- (void)bindDeviceToken:(NSString *)deviceToken;

- (void)sendMessage:(ONOBaseMessage *)message to:(NSString *)userId onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error;
- (void)readMessage:(NSString *)messageId onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error;



@end

