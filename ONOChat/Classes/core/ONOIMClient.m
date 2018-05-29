//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import "ONOIMClient.h"
#import "ONOCore.h"
#import "BSONIdGenerator.h"

#import "ONODB.h"
#import "ONOTextMessage.h"
#import "ONOImageMessage.h"
#import "ONOAudioMessage.h"



@interface ONOIMClient()


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
        [[ONOCore sharedCore] addListenerForRoute:@"push.Message" withCallback:^(Message *msg) {
            [self receiveMessage:msg];
        }];
    }
    return self;
}

- (void)receiveMessage:(Message *)msg {
    //通知服务端已收到
    [self readMessage:msg.mid onSuccess:nil onError:nil];
    //创建消息
    ONOMessage *message = [self createMessageByType:msg.type];
    message.messageId = msg.mid;
    message.timestamp = msg.time;
    message.isSend = YES;
    message.isSelf = [msg.from isEqualToString:[ONOCore sharedCore].userId];
    message.targetId = message.isSelf ? msg.to : msg.from;
    [message decode:msg.data_p];
    
    //填充用户信息,目前只有好友才发消息，所以不会存在user为空
    message.user = [ONODB fetchUser:message.targetId];
    //保存消息
    [ONODB insertMessage:message];
    //更新会话信息
    [self updateConversationWithMessage:message];
    
    //回调事件
    if (self.receiveMessageDelegate) {
        [self.receiveMessageDelegate onReceived:message];
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
        //获取自身信息
        NSString *userId = msg.user.uid;
        ONOUser *user = [[ONOUser alloc] init];
        user.userId = msg.user.uid;
        user.nickname = msg.user.name;
        user.avatar = msg.user.avatar;
        user.gender = msg.user.gender;
        if ([ONODB fetchUser:userId] == nil) {
            [ONODB insertUser:user];
        } else {
            [ONODB updateUser:user];
        }
        successBlock(user);
        
        //同步联系人
        if (msg.friendOperations != nil) {
            for (UserData *u in msg.friendOperations.addsArray) {
                //add
                ONOUser *user = [[ONOUser alloc] init];
                user.userId = u.uid;
                user.nickname = u.name;
                user.avatar = u.avatar;
                user.gender = u.gender;
                [ONODB insertOrUpdateUser:user];
                [ONODB insertOrUpdateFriend:u.uid];
            }
            for (NSString *uid in msg.friendOperations.deletesArray) {
                [ONODB deleteFriend:uid];
            }
        }

        //接着收信息
        if (msg.messagesArray_Count > 0) {
            for (Message *m in msg.messagesArray) {
                ONOMessage *message = [self createMessageByType:m.type];
                message.messageId = m.mid;
                message.timestamp = m.time;
                message.isSend = YES;
                message.isSelf = [m.from isEqualToString:[ONOCore sharedCore].userId];
                message.targetId = message.isSelf ? m.to : m.from;
                [message decode:m.data_p];

                //填充用户信息,目前只有好友才发消息，所以不会存在user为空
                message.user = [ONODB fetchUser:message.targetId];
                //保存消息
                [ONODB insertMessage:message];
                //更新会话信息
                [self updateConversationWithMessage:message];
            }
        }

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
    [[ONOCore sharedCore] requestRoute:@"client.message.readMessage" withMessage:request onSuccess:success onError:error];
}


- (NSArray <ONOConversation *>*)getConversationList {
    return [ONODB fetchConversations];
}

- (ONOConversation *)getConversation:(NSString *)targetId {
    return [ONODB fetchConversation:targetId];
}

- (ONOConversation *)getOrCreateConversation:(ONOUser *)user {
    ONOConversation *conversation = [ONODB fetchConversation:user.userId];
    if (conversation == nil) {
        conversation = [[ONOConversation alloc] init];
        [ONODB insertConversation:conversation];
    }
    return conversation;
}

- (void)updateConversation:(ONOConversation *)conversation {
    return [ONODB updateConversation:conversation];
}

- (void)updateConversationWithMessage:(ONOMessage *)message {
    ONOConversation *conversation = [ONODB fetchConversation:message.user.userId];
    BOOL isExists = NO;
    if (conversation == nil) {
        conversation = [[ONOConversation alloc] init];
    } else {
        isExists = YES;
    }
    conversation.unreadCount++;
    conversation.lastMessage = message;
    conversation.contactTime = [[NSDate date] timeIntervalSince1970];
    conversation.user = message.user;
    if (isExists) {
        [ONODB updateConversation:conversation];
    } else {
        [ONODB insertConversation:conversation];
    }
}

- (int)totalUnreadCount {
    return [ONODB totalUnreadCount];
}


- (void)userProfile:(NSString *)userId onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    [self userProfile:userId withCache:YES onSuccess:successBlock onError:errorBlock];
}

- (void)userProfile:(NSString *)userId withCache:(BOOL)withCache onSuccess:(void (^)(ONOUser *user))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
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
        user.avatar = msg.user.avatar;
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

- (void)userProfiles:(NSArray<NSString*> *)userIds onSuccess:(void (^)(NSArray<ONOUser *> *users))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    UserProfilesRequest *request = [[UserProfilesRequest alloc] init];
    [request.uidsArray addObjectsFromArray:userIds];
    [[ONOCore sharedCore] requestRoute:@"client.user.profiles" withMessage:request onSuccess:^(UserProfilesResponse *msg) {
        NSMutableArray<ONOUser *>* users = [NSMutableArray array];
        for (UserData* _user in msg.usersArray) {
            ONOUser *user = [[ONOUser alloc] init];
            user.userId = _user.uid;
            user.nickname = _user.name;
            user.avatar = _user.avatar;
            user.gender = _user.gender;
            if ([ONODB fetchUser:user.userId] == nil) {
                [ONODB insertUser:user];
            } else {
                [ONODB updateUser:user];
            }
            [users addObject:user];
        }
        if (successBlock) successBlock(users);
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}


- (NSArray<ONOUser *> *)getFriends {
    
    return [ONODB getFriends];
}

/**
 *  从服务端获取好友列表,并且更新本地数据库好友信息.(登陆之后内部调用)
 */
- (void)updateMyFriendsFromServerOnSuccess:(void (^)(NSArray<ONOUser *> *userArray))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendListRequest *request = [[FriendListRequest alloc] init];
    
    [[ONOCore sharedCore] requestRoute:@"client.friend.list" withMessage:request onSuccess:^(FriendListResponse *msg) {
        
//        if (msg.uidsArray.count == 0) {
//            if (successBlock) successBlock([NSArray new]);
//        } else {
//            // 需要更新的 user
//            [[ONOIMClient sharedClient] userProfiles:msg.uidsArray withCache:YES onSuccess:^(NSArray<ONOUser *> *userArray) {
//                if (successBlock) successBlock(userArray);
//            } onError:^(int errorCode, NSString *messageId) {
//                if (errorBlock) errorBlock(errorCode, messageId);
//            }];
//        }
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

@end
