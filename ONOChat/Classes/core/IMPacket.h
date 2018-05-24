//
//  LMChatMessage.h
//  Lemeng
//
//  Created by Kevin Lai on 14-8-20.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    IM_PT_HANDSHAKE = 1,
    IM_PT_HANDSHAKE_ACK,
    IM_PT_HEARTBEAT,
    IM_PT_DATA,
    IM_PT_KICK
} IMPacketType;

@interface IMPacket : NSObject

@property(nonatomic) IMPacketType type;
@property(nonatomic, strong) NSData *data;

- (instancetype)initWithType:(IMPacketType)type andData:(NSData *)data;

@end
