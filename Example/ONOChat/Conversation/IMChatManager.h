//
//  IMChatManager.h
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/9.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ONOMessage.h"
#import "ONOIMClient.h"


@protocol IMReceiveMessageDelegate <NSObject>
@optional
- (void)onReceived:(ONOMessage *)message;

- (void)onGetUnreadMessages;

@end

/** 用户好友相关操作delegate */
@protocol IMReceiveFriendMessageDelegate <NSObject>
@optional
/** 接到好友请求 */
- (void)onReceivedNewFriendRequest:(NSString *)message;
/** 新的好友 */
- (void)onReceivedNewFriend:(NSString *)message;
/** 好友列表更新,刷新好友列表即可 */
- (void)onReceivedFriendListUpdate;
@end



@interface IMChatManager : NSObject

+ (IMChatManager *)sharedChatManager;

/**
 *  添加多媒体委托
 *
 *  @param delegate 多媒体委托
 */
- (void)addReceiveMessageDelegate:(id<IMReceiveMessageDelegate>)delegate;

/**
 *  移除多媒体委托
 *
 *  @param delegate 多媒体委托
 */
- (void)removeReceiveMessageDelegate:(id<IMReceiveMessageDelegate>)delegate;


/** 用户好友相关操作delegate */
@property (nonatomic, weak) id<IMReceiveFriendMessageDelegate> receiveFriendMessageDelegate;

/** 登陆时候监听一些消息 */
- (void)statListenOtherMessage;
/** 退出登陆时候取消监听一些消息 */
- (void)stopListenOtherMessage;

@end
