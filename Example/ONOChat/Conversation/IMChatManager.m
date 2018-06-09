//
//  IMChatManager.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/9.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMChatManager.h"

@interface IMChatManager ()<ONOReceiveMessageDelegate>

@property (nonatomic, strong) NSMutableArray *delegateArray;

@end

@implementation IMChatManager

+ (IMChatManager *)sharedChatManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[IMChatManager alloc] init];
        [ONOIMClient sharedClient].receiveMessageDelegate = _sharedObject;
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
    
}

#pragma mark - ONOReceiveMessageDelegate
- (void)onReceived:(ONOMessage *)message {
    for (id<IMReceiveMessageDelegate> delegate in self.delegateArray) {
        if ([delegate conformsToProtocol:@protocol(IMReceiveMessageDelegate)]) {
            [delegate onReceived:message];
        }
    }
}


@end
