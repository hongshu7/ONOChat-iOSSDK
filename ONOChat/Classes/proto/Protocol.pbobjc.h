// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: protocol.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class FriendOperations;
@class Message;
@class NewFriendRequest;
@class UserData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ProtocolRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface ProtocolRoot : GPBRootObject
@end

#pragma mark - UserData

typedef GPB_ENUM(UserData_FieldNumber) {
  UserData_FieldNumber_Uid = 1,
  UserData_FieldNumber_Name = 2,
  UserData_FieldNumber_Avatar = 3,
  UserData_FieldNumber_Gender = 4,
  UserData_FieldNumber_Ex = 5,
};

/**
 * 有推送 用户信息
 **/
@interface UserData : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@property(nonatomic, readwrite, copy, null_resettable) NSString *avatar;

/** 用户性别，0表示未知，1表示男，2女表示女，其它会报参数错误 */
@property(nonatomic, readwrite) int32_t gender;

/** 用户名片扩展字段，最大长度1024字符，用户可自行扩展，建议封装成JSON字符串 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *ex;

@end

#pragma mark - Message

typedef GPB_ENUM(Message_FieldNumber) {
  Message_FieldNumber_Mid = 1,
  Message_FieldNumber_Type = 2,
  Message_FieldNumber_From = 3,
  Message_FieldNumber_To = 4,
  Message_FieldNumber_Data_p = 5,
  Message_FieldNumber_Time = 6,
  Message_FieldNumber_User = 7,
};

@interface Message : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *mid;

@property(nonatomic, readwrite) int32_t type;

@property(nonatomic, readwrite, copy, null_resettable) NSString *from;

@property(nonatomic, readwrite, copy, null_resettable) NSString *to;

@property(nonatomic, readwrite, copy, null_resettable) NSString *data_p;

@property(nonatomic, readwrite) double time;

@property(nonatomic, readwrite, strong, null_resettable) UserData *user;
/** Test to see if @c user has been set. */
@property(nonatomic, readwrite) BOOL hasUser;

@end

#pragma mark - Friend

typedef GPB_ENUM(Friend_FieldNumber) {
  Friend_FieldNumber_Uid = 1,
  Friend_FieldNumber_Remark = 2,
};

@interface Friend : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@property(nonatomic, readwrite, copy, null_resettable) NSString *remark;

@end

#pragma mark - ErrorResponse

typedef GPB_ENUM(ErrorResponse_FieldNumber) {
  ErrorResponse_FieldNumber_Code = 1,
  ErrorResponse_FieldNumber_Message = 2,
  ErrorResponse_FieldNumber_Extra = 3,
};

@interface ErrorResponse : GPBMessage

@property(nonatomic, readwrite) int32_t code;

@property(nonatomic, readwrite, copy, null_resettable) NSString *message;

@property(nonatomic, readwrite, copy, null_resettable) NSString *extra;

@end

#pragma mark - UserKick

typedef GPB_ENUM(UserKick_FieldNumber) {
  UserKick_FieldNumber_Content = 1,
};

/**
 * 推送 重复登录被提出
 **/
@interface UserKick : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *content;

@end

#pragma mark - NewFriend

typedef GPB_ENUM(NewFriend_FieldNumber) {
  NewFriend_FieldNumber_User = 1,
  NewFriend_FieldNumber_FriendSyncTag = 2,
};

/**
 * 推送 新的好友
 **/
@interface NewFriend : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) UserData *user;
/** Test to see if @c user has been set. */
@property(nonatomic, readwrite) BOOL hasUser;

@property(nonatomic, readwrite) int64_t friendSyncTag;

@end

#pragma mark - NewFriendRequest

typedef GPB_ENUM(NewFriendRequest_FieldNumber) {
  NewFriendRequest_FieldNumber_User = 1,
  NewFriendRequest_FieldNumber_Greeting = 2,
};

/**
 * 推送 新的好友请求
 **/
@interface NewFriendRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) UserData *user;
/** Test to see if @c user has been set. */
@property(nonatomic, readwrite) BOOL hasUser;

/** 招呼内容 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *greeting;

@end

#pragma mark - FriendOperations

typedef GPB_ENUM(FriendOperations_FieldNumber) {
  FriendOperations_FieldNumber_AddsArray = 1,
  FriendOperations_FieldNumber_UpdatesArray = 2,
  FriendOperations_FieldNumber_DeletesArray = 3,
  FriendOperations_FieldNumber_FriendSyncTag = 4,
};

@interface FriendOperations : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<UserData*> *addsArray;
/** The number of items in @c addsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger addsArray_Count;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<UserData*> *updatesArray;
/** The number of items in @c updatesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger updatesArray_Count;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *deletesArray;
/** The number of items in @c deletesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger deletesArray_Count;

@property(nonatomic, readwrite) int64_t friendSyncTag;

@end

#pragma mark - UserLoginRequest

typedef GPB_ENUM(UserLoginRequest_FieldNumber) {
  UserLoginRequest_FieldNumber_Token = 1,
};

/**
 * 请求 登陆接口
 **/
@interface UserLoginRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *token;

@end

#pragma mark - UserLoginResponse

typedef GPB_ENUM(UserLoginResponse_FieldNumber) {
  UserLoginResponse_FieldNumber_User = 1,
};

/**
 * 响应 登陆
 **/
@interface UserLoginResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) UserData *user;
/** Test to see if @c user has been set. */
@property(nonatomic, readwrite) BOOL hasUser;

@end

#pragma mark - UserProfileRequest

typedef GPB_ENUM(UserProfileRequest_FieldNumber) {
  UserProfileRequest_FieldNumber_Uid = 1,
};

@interface UserProfileRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@end

#pragma mark - UserProfileResponse

typedef GPB_ENUM(UserProfileResponse_FieldNumber) {
  UserProfileResponse_FieldNumber_User = 1,
};

@interface UserProfileResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) UserData *user;
/** Test to see if @c user has been set. */
@property(nonatomic, readwrite) BOOL hasUser;

@end

#pragma mark - UserProfilesRequest

typedef GPB_ENUM(UserProfilesRequest_FieldNumber) {
  UserProfilesRequest_FieldNumber_UidsArray = 1,
};

@interface UserProfilesRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *uidsArray;
/** The number of items in @c uidsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger uidsArray_Count;

@end

#pragma mark - UserProfilesResponse

typedef GPB_ENUM(UserProfilesResponse_FieldNumber) {
  UserProfilesResponse_FieldNumber_UsersArray = 1,
};

@interface UserProfilesResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<UserData*> *usersArray;
/** The number of items in @c usersArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger usersArray_Count;

@end

#pragma mark - GetUnreadMessagesRequest

@interface GetUnreadMessagesRequest : GPBMessage

@end

#pragma mark - GetUnreadMessagesResponse

typedef GPB_ENUM(GetUnreadMessagesResponse_FieldNumber) {
  GetUnreadMessagesResponse_FieldNumber_MessagesArray = 1,
};

@interface GetUnreadMessagesResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<Message*> *messagesArray;
/** The number of items in @c messagesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger messagesArray_Count;

@end

#pragma mark - GetNewMessagesRequest

typedef GPB_ENUM(GetNewMessagesRequest_FieldNumber) {
  GetNewMessagesRequest_FieldNumber_OffsetMessageId = 1,
};

@interface GetNewMessagesRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *offsetMessageId;

@end

#pragma mark - GetNewMessagesResponse

typedef GPB_ENUM(GetNewMessagesResponse_FieldNumber) {
  GetNewMessagesResponse_FieldNumber_MessagesArray = 1,
};

@interface GetNewMessagesResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<Message*> *messagesArray;
/** The number of items in @c messagesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger messagesArray_Count;

@end

#pragma mark - ReadMessageRequest

typedef GPB_ENUM(ReadMessageRequest_FieldNumber) {
  ReadMessageRequest_FieldNumber_Mid = 1,
};

/**
 * 请求 标记消息已读
 **/
@interface ReadMessageRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *mid;

@end

#pragma mark - SendMessageRequest

typedef GPB_ENUM(SendMessageRequest_FieldNumber) {
  SendMessageRequest_FieldNumber_Type = 1,
  SendMessageRequest_FieldNumber_To = 2,
  SendMessageRequest_FieldNumber_Data_p = 3,
  SendMessageRequest_FieldNumber_Mid = 4,
};

/**
 * 请求 发送消息
 **/
@interface SendMessageRequest : GPBMessage

/** 1文字 2图片 3表情 */
@property(nonatomic, readwrite) int32_t type;

/** 接收者id */
@property(nonatomic, readwrite, copy, null_resettable) NSString *to;

@property(nonatomic, readwrite, copy, null_resettable) NSString *data_p;

@property(nonatomic, readwrite, copy, null_resettable) NSString *mid;

@end

#pragma mark - SendMessagenResponse

typedef GPB_ENUM(SendMessagenResponse_FieldNumber) {
  SendMessagenResponse_FieldNumber_Omid = 1,
  SendMessagenResponse_FieldNumber_Nmid = 2,
};

/**
 * 响应 发送消息
 **/
@interface SendMessagenResponse : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *omid;

@property(nonatomic, readwrite, copy, null_resettable) NSString *nmid;

@end

#pragma mark - FriendUpdatesRequest

typedef GPB_ENUM(FriendUpdatesRequest_FieldNumber) {
  FriendUpdatesRequest_FieldNumber_FriendSyncTag = 1,
};

/**
 * 请求 好友列表
 **/
@interface FriendUpdatesRequest : GPBMessage

@property(nonatomic, readwrite) int64_t friendSyncTag;

@end

#pragma mark - FriendUpdatesResponse

typedef GPB_ENUM(FriendUpdatesResponse_FieldNumber) {
  FriendUpdatesResponse_FieldNumber_FriendOperations = 1,
};

/**
 * 响应 好友列表
 **/
@interface FriendUpdatesResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) FriendOperations *friendOperations;
/** Test to see if @c friendOperations has been set. */
@property(nonatomic, readwrite) BOOL hasFriendOperations;

@end

#pragma mark - FriendRequestRequest

typedef GPB_ENUM(FriendRequestRequest_FieldNumber) {
  FriendRequestRequest_FieldNumber_Uid = 1,
  FriendRequestRequest_FieldNumber_Greeting = 2,
};

/**
 * 请求 发起好友请求
 **/
@interface FriendRequestRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

/** 招呼内容 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *greeting;

@end

#pragma mark - FriendRequestListRequest

typedef GPB_ENUM(FriendRequestListRequest_FieldNumber) {
  FriendRequestListRequest_FieldNumber_Limit = 1,
  FriendRequestListRequest_FieldNumber_Offset = 2,
};

/**
 * 请求 好友请求列表
 **/
@interface FriendRequestListRequest : GPBMessage

/** 条数 */
@property(nonatomic, readwrite) int32_t limit;

/** 分页之前的最一条的createdAt */
@property(nonatomic, readwrite, copy, null_resettable) NSString *offset;

@end

#pragma mark - FriendRequestListResponse

typedef GPB_ENUM(FriendRequestListResponse_FieldNumber) {
  FriendRequestListResponse_FieldNumber_RequestListArray = 1,
};

/**
 * 响应 好友请求列表
 **/
@interface FriendRequestListResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NewFriendRequest*> *requestListArray;
/** The number of items in @c requestListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger requestListArray_Count;

@end

#pragma mark - FriendAgreeRequest

typedef GPB_ENUM(FriendAgreeRequest_FieldNumber) {
  FriendAgreeRequest_FieldNumber_Uid = 1,
};

/**
 * 请求 同意好友请求
 **/
@interface FriendAgreeRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@end

#pragma mark - FriendAgreeResponse

typedef GPB_ENUM(FriendAgreeResponse_FieldNumber) {
  FriendAgreeResponse_FieldNumber_FriendSyncTag = 1,
};

/**
 * 响应 同意好友请求
 **/
@interface FriendAgreeResponse : GPBMessage

@property(nonatomic, readwrite) int64_t friendSyncTag;

@end

#pragma mark - FriendIgnoreRequest

typedef GPB_ENUM(FriendIgnoreRequest_FieldNumber) {
  FriendIgnoreRequest_FieldNumber_Uid = 1,
};

/**
 * 请求 忽略好友请求
 **/
@interface FriendIgnoreRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@end

#pragma mark - FriendDeleteRequest

typedef GPB_ENUM(FriendDeleteRequest_FieldNumber) {
  FriendDeleteRequest_FieldNumber_Uid = 1,
};

/**
 * 请求 删除好友请求
 **/
@interface FriendDeleteRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@end

#pragma mark - FriendDeleteResponse

typedef GPB_ENUM(FriendDeleteResponse_FieldNumber) {
  FriendDeleteResponse_FieldNumber_FriendSyncTag = 1,
};

/**
 * 响应 删除好友请求
 **/
@interface FriendDeleteResponse : GPBMessage

@property(nonatomic, readwrite) int64_t friendSyncTag;

@end

#pragma mark - FriendSearchRequest

typedef GPB_ENUM(FriendSearchRequest_FieldNumber) {
  FriendSearchRequest_FieldNumber_Keyword = 1,
};

/**
 * 请求 好友模糊查找
 **/
@interface FriendSearchRequest : GPBMessage

/** 关键字 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *keyword;

@end

#pragma mark - FriendSearchResponse

typedef GPB_ENUM(FriendSearchResponse_FieldNumber) {
  FriendSearchResponse_FieldNumber_UsersArray = 1,
};

/**
 * 响应 好友模糊查找
 **/
@interface FriendSearchResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<UserData*> *usersArray;
/** The number of items in @c usersArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger usersArray_Count;

@end

#pragma mark - FriendRemarkRequest

typedef GPB_ENUM(FriendRemarkRequest_FieldNumber) {
  FriendRemarkRequest_FieldNumber_Uid = 1,
  FriendRemarkRequest_FieldNumber_Remark = 2,
};

/**
 * 请求 好友备注
 **/
@interface FriendRemarkRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *uid;

@property(nonatomic, readwrite, copy, null_resettable) NSString *remark;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
