//
//  [IMAPI data]
//  Dida
//
//  Created by Kevin Lai on 15/5/9.
//  Copyright (c) 2018年 Xiamen ONO technology. All rights reserved.
//

#import "ONOIMClient.h"
#import "ONOCore.h"
#import "BSONIdGenerator.h"

#import "ONODB.h"
#import "ONOTextMessage.h"
#import "ONOImageMessage.h"
#import "ONOAudioMessage.h"



@interface ONOIMClient()

@property (nonatomic, strong) NSMutableDictionary<NSString *, ONOBaseMessage*> *userQuerys;

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
        _userQuerys = [NSMutableDictionary dictionary];
        [[ONOCore sharedCore] addListenerForRoute:@"push.Message" withCallback:^(Message *msg) {
            [self receiveMessage:msg];
        }];
    }
    return self;
}

- (void)receiveMessage:(Message *)msg {
    //通过服务端已收到
    [self readMessage:msg.mid onSuccess:nil onError:nil];
    //创建消息
    ONOBaseMessage *mb = [self createMessageByType:msg.type];
    mb.messageId = msg.mid;
    mb.timestamp = msg.time;
    [mb decode:msg.data_p];
    NSString *userId = msg.from;
    ONOUser *user =  [ONODB fetchUser:msg.from];
    if (user == nil) {
        _userQuerys[msg.from] = mb;
        return;
    }
    mb.user = user;
    if (self.receiveMessageDelegate) {
        [self.receiveMessageDelegate onReceived:mb];
    }
}

#pragma mark public apis

- (void)setupWithHost:(NSString*)host port:(int)port
{
    [[ONOCore sharedCore] setupWithHost:host port:port];
}


- (ONOBaseMessage *)createMessageByType:(int)type {
    ONOBaseMessage *msg = nil;
    if (type == 1) {
        msg = [[ONOTextMessage alloc] init];
    } else if (type == 2) {
        msg = [[ONOImageMessage alloc] init];
    } else if (type == 3) {
        msg = [[ONOAudioMessage alloc] init];
    } else {
        //todo:custom types
    }
    return msg;
}

- (void)loginWithToken:(NSString *)token onSuccess:(void(^)(ONOUser *user))successBlock onError:(void(^)(int errorCode, NSString *errorMsg))errorBlock
{
    [[ONOCore sharedCore] loginWithToken:token onSuccess:^(UserLoginResponse* msg) {
        NSString *userId = msg.user.uid;
        ONOUser *user = [[ONOUser alloc] init];
        user.userId = msg.user.uid;
        user.nickname = msg.user.name;
        user.avatar = msg.user.icon;
        user.gender = msg.user.gender;
        if ([ONODB fetchUser:userId] == nil) {
            [ONODB insertUser:user];
        } else {
            [ONODB updateUser:user];
        }
        successBlock(user);
    } onError:^(ErrorResponse *msg) {
        errorBlock(msg.code, msg.message);
    }];
}

- (void)sendMessage:(ONOBaseMessage *)message to:(NSString *)userId onSuccess:(void (^)(NSString *messageId))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    
    //create msgid
    message.messageId = [BSONIdGenerator generate];
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    message.isSelf = YES;
    [ONODB insertMessage:message to:userId];
    
    SendMessageRequest *request = [[SendMessageRequest alloc] init];
    request.to = userId;
    request.type = (int)[message type];
    request.data_p = [message encode];
    request.mid = message.messageId;
    NSString *msgId = [message.messageId copy];
    [[ONOCore sharedCore] requestRoute:@"client.message.sendMessage" withMessage:request onSuccess:^(SendMessagenResponse *response) {
        [ONODB updateMessage:response.nmid fromOldId:response.omid];
        successBlock(response.nmid);
    } onError:^(ErrorResponse *err) {
        [ONODB updateMessageError:YES msgId:msgId];
        errorBlock(err.code, msgId);
    }];
}

- (void)readMessage:(NSString *)messageId onSuccess:(ONOSuccessResponse)success onError:(ONOErrorResponse)error
{
    ReadMessageRequest *request = [[ReadMessageRequest alloc] init];
    request.mid = messageId;
    [[ONOCore sharedCore] requestRoute:@"client.message.read" withMessage:request onSuccess:success onError:error];
}

- (void)queryUser:(NSString *)userId onSuccess:(ONOSuccessResponse)success onError:(ONOErrorResponse)error
{
    UserProfileRequest *request = [[UserProfileRequest alloc] init];
    request.uid = userId;
    
    [[ONOCore sharedCore] requestRoute:@"client.user.profile" withMessage:request onSuccess:^(UserData *msg) {
        ONOBaseMessage *bmsg = self.userQuerys[userId];
        if (bmsg == nil) {
            return;
        }
        [self.userQuerys removeObjectForKey:userId];
        ONOUser *user = [[ONOUser alloc] init];
        user.userId = msg.uid;
        user.nickname = msg.name;
        user.avatar = msg.icon;
        user.gender = msg.gender;
        bmsg.user = user;
        if ([ONODB fetchUser:userId] == nil) {
            [ONODB insertUser:user];
        } else {
            [ONODB updateUser:user];
        }
        if (self.receiveMessageDelegate) {
            [self.receiveMessageDelegate onReceived:bmsg];
        }
        
    } onError:^(id msg) {
        ONOBaseMessage *bmsg = self.userQuerys[userId];
        if (bmsg != nil) {
            [self.userQuerys removeObjectForKey:userId];
        }
    }];
}

- (NSArray <ONOConversation *>*)getConversationList {
    return [ONODB fetchConversations];
}

- (ONOConversation *)getConversation:(NSString *)userId {
    return [ONODB fetchConversation:userId];
}

@end
