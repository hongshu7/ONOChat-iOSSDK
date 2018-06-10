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
- (void)onReceived:(ONOMessage *)message;
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

/** 登陆时候监听一些消息 */
- (void)statListenOtherMessage;
/** 退出登陆时候取消监听一些消息 */
- (void)stopListenOtherMessage;

@end
