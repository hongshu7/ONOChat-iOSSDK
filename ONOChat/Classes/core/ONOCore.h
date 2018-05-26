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

//todo:重连机制，客户端保存session id
typedef void (^ONOSuccessResponse)(id msg);
typedef void (^ONOErrorResponse)(id msg);


@interface ONOCore : NSObject

+ (ONOCore *)sharedCore;

/**
 *  设置聊天服务器参数
 *
 *  @param host    帐号
 *  @param port    端口号
 */
- (void)setupWithHost:(NSString*)host port:(int)port;

/**
 *  监听消息
 *
 *  @param route      监听指定类型消息
 *  @param response   获得消息回调函数
 *  @return 监听消息的唯一标识码
 */
- (NSInteger)addListenerForRoute:(NSString *)route withCallback:(ONOSuccessResponse)response;

/**
 *  移除监听消息
 *
 *  @param listenerId      监听消息的唯一标识码
 */
- (void)removeListenerWithId:(NSInteger)listenerId;


@property (nonatomic, strong) NSString *userId;

- (void)connect;
- (void)disconnect;

- (void)handleConnected:(NSData *)response;
- (void)handleResponse:(ONOMessage *)message;

- (NSString *)getRouteByMsgId:(NSUInteger)msgId;
- (NSString *)getRouteByRouteId:(NSUInteger)routeId;
- (ONORouteInfo *)getRouteInfo:(NSString *)route;

- (void)requestRoute:(NSString *)route withMessage:(GPBMessage *)msg onSuccess:(ONOSuccessResponse)success onError:(ONOErrorResponse)error;
- (void)notifyRoute:(NSString *)route withMessage:(GPBMessage *)msg;

- (void)bindClientId:(NSString *)clientId;
- (void)bindDeviceToken:(NSString *)deviceToken;

- (void)loginWithToken:(NSString *)token onSuccess:(ONOSuccessResponse)success onError:(ONOErrorResponse)error;


@end

