//
//  IMChatManager.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/9.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMChatManager.h"
#import "IMToast.h"
#import "IMGlobalData.h"

@interface IMChatManager ()<ONOReceiveMessageDelegate,ONOReceiveUserKickDelegate, ONOReceiveFriendMessageDelegate>

@property (nonatomic, strong) NSMutableArray *delegateArray;

@end

@implementation IMChatManager

+ (IMChatManager *)sharedChatManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[IMChatManager alloc] init];
    });
    return _sharedObject;
}



- (void)addReceiveMessageDelegate:(id<IMReceiveMessageDelegate>)delegate {
    if (self.delegateArray == nil) {
        self.delegateArray = [NSMutableArray new];
    }
    
    [self.delegateArray addObject:delegate];
}


- (void)removeReceiveMessageDelegate:(id<IMReceiveMessageDelegate>)delegate{
    for (int i = ((int)self.delegateArray.count - 1) ; i >= 0 ; i--) {
        id delegateClass = [self.delegateArray objectAtIndex:i];
        if (delegate == delegateClass) {
            [self.delegateArray removeObject:delegate];
        }
    }
}

#pragma mark - ONOReceiveMessageDelegate
- (void)onReceived:(ONOMessage *)message {
    for (id<IMReceiveMessageDelegate> delegate in self.delegateArray) {
        if ([delegate conformsToProtocol:@protocol(IMReceiveMessageDelegate)]) {
            [delegate onReceived:message];
        }
    }
}


- (void)statListenOtherMessage {
    [ONOIMClient sharedClient].receiveMessageDelegate = self;
    [ONOIMClient sharedClient].receiveUserKickDelegate = self;
    [ONOIMClient sharedClient].receiveFriendMessageDelegate = self;
}
- (void)stopListenOtherMessage {
    [ONOIMClient sharedClient].receiveMessageDelegate = nil;
    [ONOIMClient sharedClient].receiveUserKickDelegate = nil;
    [ONOIMClient sharedClient].receiveFriendMessageDelegate = nil;
}

#pragma mark - ONOUserKickDelegate
- (void)onReceivedUserKick:(NSString *)message {
    [IMToast showTipMessage:message];
    [[IMGlobalData sharedData] logout];
}

#pragma mark - ONOReceiveFriendMessageDelegate
- (void)onReceivedNewFriend:(NSString *)userId {
    // 去发通知更新好友列表.
    [IMToast showTipMessage:@"有新的好友,已经存到数据库,刷新即可."];
    
}

- (void)onReceivedNewFriendRequest:(NSString *)message {
    [IMToast showTipMessage:message];
}


@end
