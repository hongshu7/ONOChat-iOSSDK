//
//  [IMAPI data]
//  Dida
//
//  Created by Kevin Lai on 15/5/9.
//  Copyright (c) 2018年 Xiamen ONO technology. All rights reserved.
//

#import "ONOIMClient.h"
#import "ONOSocket.h"
#import "ONOPacket.h"

@interface IMResponsePacket : NSObject

@property (nonatomic) NSInteger msgId;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, copy) IMSuccessResponse successResponse;
@property (nonatomic, copy) IMErrorResponse errorResponse;

@end

@implementation IMResponsePacket

@end


@interface ONOIMClient()

@property (nonatomic, strong) NSString *loginToken;
@property (nonatomic, copy) IMSuccessResponse loginSuccessCallback;
@property (nonatomic, copy) IMErrorResponse loginErrorCallback;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *deviceToken;

@property (nonatomic, strong) ONOSocket* client;
@property (nonatomic, strong) NSMutableDictionary *routes;
@property (nonatomic, strong) NSMutableDictionary *routesById;
@property (nonatomic) NSInteger heartbeatInterval;
@property (nonatomic, strong) NSMutableDictionary *responseMap;
@property (nonatomic, strong) NSMutableDictionary *pushMap;
@property (nonatomic) NSInteger listenerId;;
@end

@implementation ONOIMClient

+ (ONOIMClient*)sharedClient
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
    });
    return _sharedObject;
}

- (instancetype)init
{
    if (self = [super init]) {
        _client = [[ONOSocket alloc] init];
        _routes = [[NSMutableDictionary alloc] init];
        _routesById = [[NSMutableDictionary alloc] init];
        _responseMap = [[NSMutableDictionary alloc] init];
        _pushMap = [[NSMutableDictionary alloc] init];
        //事件监听
    }
    return self;
}

- (void)setupWithHost:(NSString*)host port:(int)port
{
    [self.client setupWithHost:host port:port];
}

#pragma mark -- socket actions
- (void)connect
{
    [self.client connect];
}

- (void)disconnect
{
    [self.client close];
}

- (void)handleConnected:(NSData *)response
{
    //routes
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    //NSLog(@"handshake:%@", dict);
    NSDictionary *sys = dict[@"sys"];
    self.heartbeatInterval = [sys[@"heartbeat"] integerValue];
    [self.routes removeAllObjects];
    [self.routesById removeAllObjects];
    NSDictionary *routes = sys[@"routes"];
    for (NSString *route in routes) {
        NSArray* routeArray = [routes[route] componentsSeparatedByString:@","];
        ONORouteInfo *routeInfo = [[ONORouteInfo alloc] init];
        routeInfo.routeId = [routeArray[0] integerValue];
        routeInfo.request = routeArray.count > 1 && ![routeArray[1] isEqualToString:@"_"] ? routeArray[1]: nil;
        routeInfo.response = routeArray.count > 2 && ![routeArray[2] isEqualToString:@"_"] ? routeArray[2]: nil;
        [self.routes setObject:routeInfo forKey:route];
        [self.routesById setObject:route forKey:routeArray[0]];
        //NSLog(@"routeid:%zd, %@, %@", routeInfo.routeId, routeInfo.request, routeInfo.response);
    }
    
    [self.client heartBeat:self.heartbeatInterval];
    
    //do login
    UserLoginRequest *clientUserLogin = [[UserLoginRequest alloc] init];
    clientUserLogin.token = _loginToken;
    [self requestRoute:@"client.user.login" withMessage:clientUserLogin onSuccess:^(UserLoginResponse *msg) {
        NSLog(@"user login response");
        //upload device token
        [self uploadDeviceToken];
        
        //todo:save uid
        if (self.loginSuccessCallback) {
            self.loginSuccessCallback(msg);
            self.loginSuccessCallback = nil;
            self.loginErrorCallback = nil;
        }
        

    } onError:^(ErrorResponse *error) {
        //not login
        NSLog(@"user login error code:%d, msg:%@", error.code, error.message);
        if (self.loginErrorCallback) {
            self.loginErrorCallback(error);
            self.loginSuccessCallback = nil;
            self.loginErrorCallback = nil;
        }
    }];
}

- (void)uploadDeviceToken
{
//    if (self.clientId != nil) {
//        DeviceBindRequest *request = [[[[DeviceBindRequest builder] setType:1] setToken:self.clientId] build];
//        [self requestRoute:@"client.user.bindDevice" withMessage:request onSuccess:^(id msg) {
//            NSLog(@"upload clientid success, token:%@", self.clientId);
//            self.clientId = nil; //only upload once
//        } onError:^(ErrorResponse *error) {
//            NSLog(@"upload clientid with error code:%d, msg:%@", error.code, error.message);
//        }];
//    }
//    if (self.deviceToken != nil) {
//        DeviceBindRequest *request = [[[[DeviceBindRequest builder] setType:2] setToken:self.deviceToken] build];
//        [self requestRoute:@"client.user.bindDevice" withMessage:request onSuccess:^(id msg) {
//            NSLog(@"upload device token success, token:%@", self.deviceToken);
//            self.deviceToken = nil; //only upload once
//        } onError:^(ErrorResponse *error) {
//            NSLog(@"upload device token with error code:%d, msg:%@", error.code, error.message);
//        }];
//    }
}

- (void)handleResponse:(ONOMessage *)message
{
    //处理回调
    if (message.messageId > 0) {
        //response
        IMResponsePacket *rp = [self.responseMap objectForKey:[@(message.messageId) stringValue]];
        if (rp) {
            [self.responseMap removeObjectForKey:[@(message.messageId) stringValue]];
            if (message.isError) {
                if (rp.errorResponse) rp.errorResponse(message.message);
            } else {
                if (rp.successResponse) rp.successResponse(message.message);
            }
            
        }
    } else {
        //push
        NSMutableArray *routeListeners = [self.pushMap objectForKey:message.route];
        if (routeListeners) {
            for (IMResponsePacket *rp in routeListeners) {
                if (rp.successResponse) rp.successResponse(message.message);
            }
        }
    }
    
}

- (NSString *)getRouteByMsgId:(NSUInteger)msgId
{
    IMResponsePacket *rp = [self.responseMap objectForKey:[@(msgId) stringValue]];
    return rp == nil ? @"" : rp.route;
}

- (NSString *)getRouteByRouteId:(NSUInteger)routeId
{
    return [self.routesById objectForKey:[@(routeId) stringValue]];
}

- (ONORouteInfo *)getRouteInfo:(NSString *)route
{
    return [self.routes objectForKey:route];
}

#pragma mark -- send
- (void)requestRoute:(NSString *)route withMessage:(GPBMessage *)msg  onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error
{
    ONOMessage *msgPacket = [[ONOMessage alloc] init];
    msgPacket.type = IM_MT_REQUEST;
    msgPacket.route = route;
    msgPacket.messageId = [self randomNumber:1 to:99999999];
    msgPacket.message = msg;
    
    //保存request
    IMResponsePacket *rp = [[IMResponsePacket alloc] init];
    rp.msgId = msgPacket.messageId;
    rp.route = route;
    rp.successResponse = success;
    rp.errorResponse = error;
    [self.responseMap setObject:rp forKey:[@(msgPacket.messageId) stringValue]];
    
    ONOPacket *packet = [[ONOPacket alloc] initWithType:IM_PT_DATA andData:[msgPacket encode]];
    [self.client sendData:packet];
}

- (void)notifyRoute:(NSString *)route withMessage:(GPBMessage *)msg
{
    ONOMessage *msgPacket = [[ONOMessage alloc] init];
    msgPacket.type = IM_MT_NOTIFY;
    msgPacket.route = route;
    msgPacket.message = msg;
    
    ONOPacket *packet = [[ONOPacket alloc] initWithType:IM_PT_DATA andData:[msgPacket encode]];
    [self.client sendData:packet];
}

- (NSInteger)addListenerForRoute:(NSString *)route withCallback:(IMSuccessResponse)response
{
    //保存request
    IMResponsePacket *rp = [[IMResponsePacket alloc] init];
    rp.msgId = self.listenerId++;
    rp.route = route;
    rp.successResponse = response;
    
    NSMutableArray *routeListeners = [self.pushMap objectForKey:route];
    if (routeListeners == nil) {
        routeListeners = [[NSMutableArray alloc] init];
        [self.pushMap setObject:routeListeners forKey:route];
    }
    [routeListeners addObject:rp];
    
    return rp.msgId;
}

- (void)removeListenerWithId:(NSInteger)listenerId
{
    BOOL found = NO;
    for (NSString *route in self.pushMap) {
        NSMutableArray *routeListeners = [self.pushMap objectForKey:route];
        for (IMResponsePacket *rp in routeListeners) {
            if (rp.msgId == listenerId) {
                [routeListeners removeObject:rp];
                found = YES;
                return;
            }
        }
        if (found) {
            return;
        }
    }
}

- (long)randomNumber:(long)from to:(long)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

#pragma mark -- login
- (void)loginWithToken:(NSString *)token onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error
{
    self.loginToken = token;
    self.loginSuccessCallback = success;
    self.loginErrorCallback = error;
    [self connect];
}

#pragma mark -- bind device token
- (void)bindClientId:(NSString *)clientId
{
    if (clientId == nil || clientId.length == 0) {
        return;
    }
    self.clientId = clientId;
    if (self.client.isConnect) {
        [self uploadDeviceToken];
    }
}

- (void)bindDeviceToken:(NSString *)deviceToken
{
    if (deviceToken == nil || deviceToken.length == 0) {
        return;
    }
    self.deviceToken = deviceToken;
    if (self.client.isConnect) {
        [self uploadDeviceToken];
    }
}

- (void)sendMessage:(ONOBaseMessage *)message to:(NSString *)userId onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error {
    SendMessageRequest *request = [[SendMessageRequest alloc] init];
    request.to = userId;
    request.type = message.type;
    request.content = message.content;
    request.tag = message.data;
    [self requestRoute:@"client.message.send" withMessage:request onSuccess:success onError:error];
}

- (void)readMessage:(NSString *)messageId onSuccess:(IMSuccessResponse)success onError:(IMErrorResponse)error
{
    ReadMessageRequest *request = [[ReadMessageRequest alloc] init];
    request.mid = messageId;
    [self requestRoute:@"client.message.read" withMessage:request onSuccess:success onError:error];
}

@end
