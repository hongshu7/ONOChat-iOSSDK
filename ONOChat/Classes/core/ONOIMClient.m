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

@property (nonatomic, strong) NSMutableDictionary<NSString *, ONOMessage*> *messagesWaitFillUser;

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
        _messagesWaitFillUser = [NSMutableDictionary dictionary];
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
    ONOMessage *mb = [self createMessageByType:msg.type];
    mb.messageId = msg.mid;
    mb.timestamp = msg.time;
    [mb decode:msg.data_p];
    ONOUser *user =  [ONODB fetchUser:msg.from];
    if (user == nil) {
        self.messagesWaitFillUser[msg.from] = mb;
        [self queryUserAsync:msg.from];
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


- (ONOMessage *)createMessageByType:(int)type {
    ONOMessage *msg = nil;
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

- (void)sendMessage:(ONOMessage *)message to:(NSString *)userId onSuccess:(void (^)(NSString *messageId))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    
    //create msgid
    message.messageId = [BSONIdGenerator generate];
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    message.isSelf = YES;
    ONOUser *user = [ONODB fetchUser:userId];
    if (user == nil) {
        user = [[ONOUser alloc] init];
        user.userId = userId;
        user.nickname = @"...";
        user.avatar = @"";
        user.gender = 1;
        [ONODB insertUser:user];
    }
    message.user = user;
    [ONODB insertMessage:message];

    ONOConversation *conversation = [self getConversation:userId];
    if (conversation == nil) {
        conversation = [[ONOConversation alloc] init];
        conversation.conversationType = ConversationTypePrivate;
        conversation.contactTime = [[NSDate date] timeIntervalSince1970];
        conversation.unreadCount = 0;
        conversation.user = user;
        conversation.lastMessage = message;
        [ONODB insertConversation:conversation];
    }
    
    SendMessageRequest *request = [[SendMessageRequest alloc] init];
    request.to = userId;
    request.type = (int)[message type];
    request.data_p = [message encode];
    request.mid = message.messageId;
    NSString *msgId = [message.messageId copy];
    [[ONOCore sharedCore] requestRoute:@"client.message.sendMessage" withMessage:request onSuccess:^(SendMessagenResponse *response) {
        [ONODB markMessageSend:response.nmid fromOldId:response.omid];
        successBlock(response.nmid);
    } onError:^(ErrorResponse *err) {
        [ONODB markMessageError:YES msgId:msgId];
        errorBlock(err.code, msgId);
    }];
}

- (void)readMessage:(NSString *)messageId onSuccess:(ONOSuccessResponse)success onError:(ONOErrorResponse)error {
    ReadMessageRequest *request = [[ReadMessageRequest alloc] init];
    request.mid = messageId;
    [[ONOCore sharedCore] requestRoute:@"client.message.read" withMessage:request onSuccess:success onError:error];
}

- (void)queryUserAsync:(NSString *)userId {
    [self userProfile:userId withCache:NO onSuccess:^(ONOUser *user) {
        ONOMessage *bmsg = self.messagesWaitFillUser[userId];
        if (bmsg != nil) {
            [self.messagesWaitFillUser removeObjectForKey:userId];
            bmsg.user = user;
            if (self.receiveMessageDelegate) {
                [self.receiveMessageDelegate onReceived:bmsg];
            }
        }
    } onError:^(int errorCode, NSString *messageId) {
        ONOMessage *bmsg = self.messagesWaitFillUser[userId];
        if (bmsg != nil) {
            [self.messagesWaitFillUser removeObjectForKey:userId];
        }
        
    }];
}

- (NSArray <ONOConversation *>*)getConversationList {
    return [ONODB fetchConversations];
}

- (ONOConversation *)getConversation:(NSString *)targetId {
    return [ONODB fetchConversation:targetId];
}

- (void)updateConversation:(ONOConversation *)conversation {
    return [ONODB updateConversation:conversation];
}

- (void)userProfile:(NSString *)userId onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    [self userProfile:userId withCache:YES onSuccess:successBlock onError:errorBlock];
}

- (void)userProfile:(NSString *)userId withCache:(BOOL)withCache onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    if (withCache) {
        ONOUser *user = [ONODB fetchUser:userId];
        if (user != nil) {
            if (successBlock) successBlock(user);
            return;
        }
    }
    UserProfileRequest *request = [[UserProfileRequest alloc] init];
    request.uid = userId;
    [[ONOCore sharedCore] requestRoute:@"client.user.profile" withMessage:request onSuccess:^(UserProfileResponse *msg) {
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
        if (successBlock) successBlock(user);
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

- (NSArray<ONOConversation *> *)getContactList {
    
    return [ONODB fetchConversations];
}

- (void)getContactListFromServerOnSuccess:(void (^)(NSArray* *userArray))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    FriendListRequest *request = [[FriendListRequest alloc] init];
    [[ONOCore sharedCore] requestRoute:@"client.friend.list" withMessage:request onSuccess:^(FriendListResponse *msg) {
        
        
        for (int i = 0;  i < msg.friendsArray.count; i++) {
            UserData *userData = [msg.friendsArray objectAtIndex:i];
            ONOUser *user = [[ONOUser alloc] init];
            user.userId = userData.uid;
            user.nickname = userData.name;
            user.avatar = userData.icon;
            user.gender = userData.gender;
            if ([ONODB fetchUser:user.userId] == nil) {
                [ONODB insertUser:user];
            } else {
                [ONODB updateUser:user];
            }
        }
        
        if (successBlock) successBlock(nil);
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

@end
