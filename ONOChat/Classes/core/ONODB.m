//
//  ChatManager.m
//  Lemeng
//
//  Created by Kevin Lai on 14-8-26.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import "ONODB.h"
#import "ONOCore.h"
#import "ONOIMClient.h"

#import <FMDB/FMDB.h>

#define DBNAME    @"message.sqlite"

static BOOL isInit;
static FMDatabase *db;


@implementation ONODB

+ (NSString *)selfUserId {
    return [ONOCore sharedCore].userId;
}

+ (void)initDB
{
    if (isInit) {
        return;
    }
    isInit = true;
    //数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *databasePath = [documentPath stringByAppendingPathComponent:DBNAME];
    NSLog(@"database path:%@", databasePath);
    db = [FMDatabase databaseWithPath:databasePath];
    if (![db open]) {
        NSLog(@"not opened");
        [db close];
    }
    if (![db tableExists:@"setting"]) {
        [self createTables];
    } else {
        [self checkVersion];
    }
//    if (![db tableExists:@"groupinfo"]) {
//        [self createGroup];
//    }
    
    [db close];
    NSLog(@"database inited!");
}

+(void)checkVersion
{
    NSString *sql = @"SELECT cvalue FROM setting";
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        NSInteger version = [rs intForColumn:@"cvalue"];
        if (version == 1) {
            [rs close];
            [self alterConversationTable];
        }
    }
}

+ (void)createTables
{
    NSString *sql = @"CREATE TABLE `conversation` ("
    "`belong_id`	TEXT NOT NULL,"
    "`target_id`	TEXT NOT NULL,"
    "`contact_time`    INTEGER NOT NULL,"
    "`conversation_type` INTEGER NOT NULL,"// 1 person  2 group
    "`unread_count`	INTEGER NOT NULL,"
    "`last_message_id`	TEXT,"
    "PRIMARY KEY(belong_id,target_id)"
    ");";
    [db executeUpdate:sql];
    sql = @"CREATE TABLE `message` ("
    "`message_id`	TEXT NOT NULL,"
    "`belong_id`	TEXT NOT NULL,"
    "`user_id`	TEXT NOT NULL,"
    "`group_id`	TEXT NOT NULL DEFAULT '',"// 群id
    "`type`	INTEGER NOT NULL DEFAULT 1,"
    "`data`	TEXT,"
    "`timestamp`	REAL DEFAULT 0,"
    "`is_send`	INTEGER DEFAULT 0,"
    "`is_self`	INTEGER DEFAULT 0,"
    "`is_error`	INTEGER DEFAULT 0,"
    "PRIMARY KEY(message_id)"
    ");";
    [db executeUpdate:sql];
    
    sql = @"CREATE TABLE `user` ("
    "`user_id`	TEXT NOT NULL,"
    "`nickname`	TEXT,"
    "`gender`	INTEGER,"
    "`avatar`	TEXT,"
    "PRIMARY KEY(user_id)"
    ");";
    [db executeUpdate:sql];

    sql = @"CREATE INDEX `conversation_list` ON `conversation` (`belong_id` ASC,`contact_time` DESC);";
    [db executeUpdate:sql];
    sql = @"CREATE UNIQUE INDEX `user_msg_list` ON `message` (`belong_id` ASC,`user_id` ASC, `message_id` DESC);";
    [db executeUpdate:sql];

    sql = @"CREATE TABLE `setting` ("
    "`ckey`	TEXT NOT NULL,"
    "`cvalue` TEXT NOT NULL,"
    "PRIMARY KEY(ckey)"
    ");";
    [db executeUpdate:sql];
    sql = @"INSERT INTO `setting`(ckey,cvalue) VALUES(?,?);";
    [db executeUpdate:sql, @"version", @"1"];
}

+ (void)createGroupTable
{
    NSString * sql = @"CREATE TABLE `groupinfo` ("
    "`group_id`	INTEGER NOT NULL,"
    "`belong_id`	INTEGER NOT NULL,"
    "`name`	TEXT,"
    "`logo`	TEXT,"
    "`master`	INTEGER NOT NULL DEFAULT 1,"
    "`crcinfo`	INTEGER,"
    "`crcmember`	INTEGER,"
    "`createTime`	INTEGER DEFAULT 0,"
    "`members`	TEXT," // ,id
    "PRIMARY KEY(group_id,belong_id)"
    ");";
    [db executeUpdate:sql];
}

+(void)alterConversationTable
{
}

+ (ONOConversation*)fetchConversation:(NSString *)targetId {
    [self initDB];
    [db open];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM conversation WHERE belong_id=? AND user_id=?",
                       [self selfUserId],
                       targetId
                       ];
    ONOConversation *conversation = nil;
    if ([rs next]) {
        conversation = [[ONOConversation alloc] init];
        //conversation.belongId = [rs stringForColumn:@"belong_id"];
        conversation.conversationType = [rs intForColumn:@"conversation_type"];
        conversation.contactTime = [rs doubleForColumn:@"contact_time"];
        conversation.unreadCount = [rs intForColumn:@"unread_count"];
        
        NSString *userId = [rs stringForColumn:@"user_id"];
        conversation.user = [self fetchUser:userId];
        NSString *lastMessageId = [rs stringForColumn:@"last_message_id"];
        if (lastMessageId != nil) {
            conversation.lastMessage = [self fetchMessage:lastMessageId];
        }
    }
    [db close];
    return conversation;
}


+ (ONOConversation*)fetchConversation:(NSString *)targetId withConversationType:(NSInteger)conversationType
{
    [self initDB];
    [db open];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM conversation WHERE belong_id=? AND target_id=? AND message_type=?",
                       [self selfUserId],
                       targetId,
                       @(conversationType)];
    ONOConversation *conversation = nil;
    if ([rs next]) {
        conversation = [[ONOConversation alloc] init];
        //conversation.belongId = [rs stringForColumn:@"belong_id"];
        conversation.conversationType = [rs intForColumn:@"conversation_type"];
        conversation.contactTime = [rs doubleForColumn:@"contact_time"];
        conversation.unreadCount = [rs intForColumn:@"unread_count"];
        
        NSString *userId = [rs stringForColumn:@"target_id"];
        conversation.user = [self fetchUser:userId];
        NSString *lastMessageId = [rs stringForColumn:@"last_message_id"];
        if (lastMessageId != nil) {
            conversation.lastMessage = [self fetchMessage:lastMessageId];
        }
    }
    [db close];
    return conversation;
}

+ (NSArray<ONOConversation *> *)fetchConversations
{
    [self initDB];
    [db open];
    NSMutableArray* conversations = [NSMutableArray new];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM conversation WHERE belong_id=?", [self selfUserId]];
    ONOConversation *conversation = nil;
    while ([rs next]) {
        conversation = [[ONOConversation alloc] init];
        //conversation.belongId = [rs stringForColumn:@"belong_id"];
        conversation.conversationType = [rs intForColumn:@"conversation_type"];
        conversation.contactTime = [rs doubleForColumn:@"contact_time"];
        conversation.unreadCount = [rs intForColumn:@"unread_count"];
        
        NSString *userId = [rs stringForColumn:@"target_id"];
        conversation.user = [self fetchUser:userId];
        NSString *lastMessageId = [rs stringForColumn:@"last_message_id"];
        if (lastMessageId != nil) {
            conversation.lastMessage = [self fetchMessage:lastMessageId];
        }
        
        [conversations addObject:conversation];
    }
    [db close];
    return conversations;
}

+ (void)insertConversation:(ONOConversation *)conversation
{
    [self initDB];
    [db open];
    NSString *sql = @"INSERT INTO conversation(belong_id,target_id,conversation_type,contact_time,unread_count,last_message_id) VALUES(?,?,?,?,?,?)";
    NSString *userId = conversation.user.userId;
    NSString *lastMessageId = @"";
    if (conversation.lastMessage != nil) {
        lastMessageId = conversation.lastMessage.messageId;
    }
    [db executeUpdate:sql,
     [self selfUserId], userId, @(conversation.conversationType), @(conversation.contactTime),@(conversation.unreadCount), lastMessageId];
    NSLog(@"INSERT INTO conversation(belong_id,target_id,conversation_type,contact_time,unread_count,last_message_id) VALUES('%@','%@','%@','%@','%@','%@')", [self selfUserId], userId, @(conversation.conversationType), @(conversation.contactTime),@(conversation.unreadCount), lastMessageId);
    [db close];
}

+ (void)updateConversation:(ONOConversation*)conversation
{
    [self initDB];
    [db open];
    NSString *sql = @"UPDATE conversation set contact_time=?, unread_count=?, last_message_id=? WHERE belong_id=? AND user_id=?";
    NSString *lastMessageId = @"";
    if (conversation.lastMessage != nil) {
        lastMessageId = conversation.lastMessage.messageId;
    }
    NSString *userId = conversation.user.userId;
    [db executeUpdate:sql,
     @(conversation.contactTime), @(conversation.unreadCount), lastMessageId, [self selfUserId], userId];
    [db close];
}

+ (void)deleteConversation:(NSString *)userId
{
    [self initDB];
    [db open];
    NSString *sql = @"DELETE FROM conversation WHERE belong_id=? AND user_id=?";
    NSLog(@"DELETE FROM conversation WHERE belong_id=%@ AND user_id=%@", [self selfUserId], userId);
    [db executeUpdate:sql, [self selfUserId], userId];
    [db close];
}


+(void)insertUser:(ONOUser *)user
{
    [self initDB];
    [db open];
    NSString *sql = @"INSERT INTO user(user_id,nickname,avatar,gender) VALUES(?,?,?,?)";
    [db executeUpdate:sql,
     user.userId, user.nickname, user.avatar, @(user.gender)];
    NSLog(@"INSERT INTO user(user_id,nickname,avatar,gender) VALUES('%@','%@','%@',%@)", user.userId, user.nickname, user.avatar, @(user.gender));
    [db close];
}

+(void)updateUser:(ONOUser *)user
{
    [self initDB];
    [db open];
    NSString *sql = @"UPDATE user set nickname=?, avatar=?, gender=? WHERE user_id=?";
    [db executeUpdate:sql, user.nickname, user.avatar, @(user.gender), user.userId];
    [db close];
}

+(ONOUser *)fetchUser:(NSString *)userId
{
    [self initDB];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM user WHERE user_id=?", userId];
    ONOUser *user = nil;
    if ([rs next]) {
        user = [[ONOUser alloc] init];
        user.userId = [rs stringForColumn:@"user_id"];
        user.nickname = [rs stringForColumn:@"nickname"];
        user.avatar = [rs stringForColumn:@"avatar"];
        user.gender = [rs intForColumn:@"gender"];
    }
    [db close];
    return user;
}

//+(NSArray *)fetchUsers:(NSString *)userIds
//{
//    NSMutableArray *userArr = [NSMutableArray array];
//    [self initDB];
//    [db open];
//    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM user WHERE user_id IN (%@)",
//                     userIds];
//    FMResultSet *rs = [db executeQuery:sql];
//    ONOUser *user = nil;
//    while ([rs next]) {
//        user = [[ONOUser alloc] init];
//        user.userId = [rs longLongIntForColumn:@"user_id"];
//        user.nickname = [rs stringForColumn:@"nickname"];
//        user.avatar = [rs stringForColumn:@"avatar"];
//        user.gender = [rs intForColumn:@"gender"];
//        [userArr addObject:user];
//    }
//    [db close];
//    return userArr;
//}

+ (ONOBaseMessage*)fetchMessage:(NSString *)msgId
{
    [self initDB];
    [db open];

    FMResultSet *rs = [db executeQuery:@"SELECT * FROM message WHERE message_id=?", msgId];
    ONOBaseMessage *message = nil;
    if ([rs next]) {
        int type = [rs intForColumn:@"type"];
        message = [[ONOIMClient sharedClient] createMessageByType:type];
        message.messageId = [rs stringForColumn:@"message_id"];
        //message.belongId = [rs stringForColumn:@"belong_id"];
        //message.groupId = [rs stringForColumn:@"group_id"];
        NSString *userId = [rs stringForColumn:@"user_id"];
        message.user = [self fetchUser:userId];
        message.timestamp = [rs doubleForColumn:@"timestamp"];
        message.isSend = [rs boolForColumn:@"is_send"];
        message.isSelf = [rs boolForColumn:@"is_self"];
        message.isError = [rs boolForColumn:@"is_error"];
        NSString *data = [rs stringForColumn:@"data"];
        [message decode:data];
    }
    [db close];
    return message;
}

+ (NSArray*)fetchMessages:(NSString *)userId offset:(NSString *)offset limit:(int)limit
{
    [self initDB];
    [db open];
    NSMutableArray* messages = [NSMutableArray new];
    FMResultSet *rs = nil;
    if (offset > 0) {
        rs = [db executeQuery:@"SELECT * FROM message WHERE belong_id=? AND user_id=? AND group_id = '0' AND message_id<? ORDER BY message_id DESC LIMIT ?",
               [self selfUserId],
               userId,
               offset,
               [NSNumber numberWithInt:limit]];
    } else {
        rs = [db executeQuery:@"SELECT * FROM message WHERE belong_id=? AND user_id=? AND group_id = '0' ORDER BY message_id DESC LIMIT ?",
              [self selfUserId],
              userId,
              [NSNumber numberWithInt:limit]];
        NSLog(@"SELECT * FROM message WHERE belong_id=%@ AND user_id=%@ ORDER BY message_id DESC LIMIT %d", [self selfUserId], userId, limit);
    }
    ONOBaseMessage *message = nil;
    while ([rs next]) {
        int type = [rs intForColumn:@"type"];
        message = [[ONOIMClient sharedClient] createMessageByType:type];
        message.messageId = [rs stringForColumn:@"message_id"];
        //message.belongId = [rs stringForColumn:@"belong_id"];
        //message.groupId = [rs stringForColumn:@"group_id"];
        NSString *userId = [rs stringForColumn:@"user_id"];
        message.user = [self fetchUser:userId];
        message.timestamp = [rs doubleForColumn:@"timestamp"];
        message.isSend = [rs boolForColumn:@"is_send"];
        message.isSelf = [rs boolForColumn:@"is_self"];
        message.isError = [rs boolForColumn:@"is_error"];
        NSString *data = [rs stringForColumn:@"data"];
        [message decode:data];
        
        [messages addObject:message];
    }
    [db close];
    return [[messages reverseObjectEnumerator] allObjects];
}


+ (void)insertMessage:(ONOBaseMessage*)message
{
    [self initDB];
    [db open];
    NSString *sql = @"INSERT INTO message(message_id,belong_id,user_id,group_id,type,data,timestamp,is_send,is_self,is_error) VALUES(?,?,?,?,?,?,?,?,?,?)";
    NSString *data = [message encode];
    [db executeUpdate:sql,
        message.messageId, [self selfUserId], message.user.userId, @"", @([message type]), data, @(message.timestamp), @(message.isSend), @(message.isSelf), @(message.isError)];
    [db close];
}

+ (void)markMessageSend:(NSString *)newMessgeId fromOldId:(NSString *)oldMessageId
{
     NSLog(@"UPDATE message SET message_id=%@, is_send=%d, is_error=%d WHERE message_id=%@", newMessgeId, YES, NO, oldMessageId);
    [self initDB];
    [db open];
    NSString *sql = @"UPDATE message SET message_id=?, is_send=?, is_error=? WHERE message_id=?";
    [db executeUpdate:sql, newMessgeId, @(YES), @(NO), oldMessageId];
    [db close];
}

+ (void)markMessageError:(BOOL)error msgId:(NSString *)msgId
{
    [self initDB];
    [db open];
    NSString *sql = @"UPDATE message SET is_error=? WHERE message_id=?";
    [db executeUpdate:sql, @(error ? 1 : 0), msgId];
    [db close];
}

+ (void)deleteMessage:(NSString *)userId msgId:(NSString *)msgId
{
    [self initDB];
    [db open];
    NSString *sql = @"DELETE FROM message WHERE message_id=?";
    [db executeUpdate:sql, msgId];
    [db close];
}

@end
