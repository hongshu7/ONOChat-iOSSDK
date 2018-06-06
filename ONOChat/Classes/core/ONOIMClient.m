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
    message.userId = msg.from;
    [message decode:msg.data_p];
    //保存消息
    [ONODB insertMessage:message];
    //更新会话信息
    [self updateConversation:message.targetId withMessage:message];
    
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
        //todo:每分钟自动同步联系人

        //接着收信息
        if (msg.messagesArray_Count > 0) {
            for (Message *m in msg.messagesArray) {
                ONOMessage *message = [self createMessageByType:m.type];
                message.messageId = m.mid;
                message.timestamp = m.time;
                message.isSend = YES;
                message.isSelf = [m.from isEqualToString:[ONOCore sharedCore].userId];
                message.targetId = message.isSelf ? m.to : m.from;
                message.userId = m.from;
                [message decode:m.data_p];

                //保存消息
                [ONODB insertMessage:message];
                //更新会话信息
                [self updateConversation:message.targetId withMessage:message];
            }
        }

    } onError:^(ErrorResponse *msg) {
        errorBlock(msg.code, msg.message);
    }];
}

- (void)sendMessage:(ONOMessage *)message to:(NSString *)targetId onSuccess:(void (^)(NSString *messageId))successBlock onError:(void (^)(int errorCode, NSString *messageId))errorBlock {
    
    //create msgid
    message.messageId = [BSONIdGenerator generate];
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    message.isSelf = YES;
    message.targetId = targetId;
    message.userId = [ONOCore sharedCore].userId;
    message.user = [ONOCore sharedCore].user;
    [ONODB insertMessage:message];

    [self updateConversation:targetId withMessage:message];
    
    SendMessageRequest *request = [[SendMessageRequest alloc] init];
    request.to = targetId;
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

- (void)updateConversation:(ONOConversation *)conversation {
    return [ONODB updateConversation:conversation];
}

- (void)updateConversation:(NSString *)targetId withMessage:(ONOMessage *)message {
    ONOConversation *conversation = [ONODB fetchConversation:targetId];
    BOOL isExists = NO;
    if (conversation == nil) {
        conversation = [[ONOConversation alloc] init];
        conversation.user = [ONODB fetchUser:targetId];
    } else {
        isExists = YES;
    }
    if (message.isSelf) {
        conversation.unreadCount = 0;
    } else {
        conversation.unreadCount++;
    }
    conversation.lastMessage = message;
    conversation.contactTime = [[NSDate date] timeIntervalSince1970];
    if (isExists) {
        [ONODB updateConversation:conversation];
    } else {
        [ONODB insertConversation:conversation];
    }
}

- (NSArray <ONOMessage *> *)getMessageList:(NSString *)targetId offset:(NSString *)offset limit:(int)limit {
    NSArray <ONOMessage *> *msgs = [ONODB fetchMessages:targetId offset:offset limit:limit];
    ONOUser *targetUser = [ONODB fetchUser:targetId];
    for (ONOMessage *msg in msgs) {
        msg.user = msg.isSelf ? [ONOCore sharedCore].user : targetUser;
    }
    return msgs;
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

- (void)friendListUpdateByUpdateTimestamp:(long)updateTimestamp onSuccess:(void (^)(NSArray<ONOUser *> *userArray))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendUpdatesRequest *request = [[FriendUpdatesRequest alloc] init];
    
    [[ONOCore sharedCore] requestRoute:@"client.friend.updates" withMessage:request onSuccess:^(FriendUpdatesResponse *msg) {
        
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


- (void)friendSearchByKeyword:(NSString *)keyword onSuccess:(void (^)(NSArray<ONOUser *> *userArray))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendSearchRequest *request = [[FriendSearchRequest alloc] init];
    request.keyword = keyword;
    [[ONOCore sharedCore] requestRoute:@"client.friend.search" withMessage:request onSuccess:^(FriendSearchResponse *msg) {
        
        NSMutableArray<ONOUser*> *onoUserArray = [NSMutableArray new];
        for (UserData *userData in msg.usersArray) {
            ONOUser *user = [[ONOUser alloc] init];
            user.userId = userData.uid;
            user.nickname = userData.name;
            user.avatar = userData.avatar;
            user.gender = userData.gender;
            [onoUserArray addObject:user];
        }
        
      if (successBlock) successBlock(onoUserArray);
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

- (void)friendAddWithUserId:(NSString *)usrId andGreeting:(NSString *)greeting onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendRequestRequest *request = [[FriendRequestRequest alloc] init];
    request.greeting = greeting;
    request.uid = usrId;
    [[ONOCore sharedCore] requestRoute:@"client.friend.request" withMessage:request onSuccess:^(id msg) {
        if (successBlock) successBlock();
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}



- (void)friendRequestListWithLimit:(int)limit andOffset:(NSString *)offset onSuccess:(void (^)(NSArray<ONOFriendRequest *> *friendRequest))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendRequestListRequest *request = [[FriendRequestListRequest alloc] init];
    request.limit = limit;
    request.offset = offset;
    [[ONOCore sharedCore] requestRoute:@"client.friend.requestList" withMessage:request onSuccess:^(FriendRequestListResponse *msg) {
        NSMutableArray<ONOFriendRequest*> *onoFriendRequestArray = [NSMutableArray new];
        for (NewFriendRequest *friendRequest in msg.requestListArray) {
            ONOFriendRequest *onofriendRequest = [[ONOFriendRequest alloc] init];
            onofriendRequest.user.userId = friendRequest.user.uid;
            onofriendRequest.user.nickname = friendRequest.user.name;
            onofriendRequest.user.avatar = friendRequest.user.avatar;
            onofriendRequest.user.gender = friendRequest.user.gender;
            onofriendRequest.greeting = friendRequest.greeting;
            [onoFriendRequestArray addObject:onofriendRequest];
        }
        
        if (successBlock) successBlock(onoFriendRequestArray);
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}


- (void)friendAgreeWithUserId:(NSString *)usrId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendAgreeRequest *request = [[FriendAgreeRequest alloc] init];
    request.uid = usrId;
    [[ONOCore sharedCore] requestRoute:@"client.friend.agree" withMessage:request onSuccess:^(id msg) {
        if (successBlock) successBlock();
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

- (void)friendIgnoreWithUserId:(NSString *)usrId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendIgnoreRequest *request = [[FriendIgnoreRequest alloc] init];
    request.uid = usrId;
    [[ONOCore sharedCore] requestRoute:@"client.friend.ignore" withMessage:request onSuccess:^(id msg) {
        if (successBlock) successBlock();
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

- (void)friendDeleteWithUserId:(NSString *)usrId onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendDeleteRequest *request = [[FriendDeleteRequest alloc] init];
    request.uid = usrId;
    [[ONOCore sharedCore] requestRoute:@"client.friend.delete" withMessage:request onSuccess:^(id msg) {
        if (successBlock) successBlock();
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

- (void)friendRemarkWithUserId:(NSString *)usrId andAlias:(NSString *)alias onSuccess:(void (^)(void))successBlock onError:(void (^)(int errorCode, NSString *errorMessage))errorBlock {
    FriendRemarkRequest *request = [[FriendRemarkRequest alloc] init];
    request.remark = alias;
    request.uid = usrId;
    [[ONOCore sharedCore] requestRoute:@"client.friend.remark" withMessage:request onSuccess:^(id msg) {
        if (successBlock) successBlock();
    } onError:^(ErrorResponse *msg) {
        if (errorBlock) errorBlock(msg.code, msg.message);
    }];
}

@end
