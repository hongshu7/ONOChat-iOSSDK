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
} ONOPacketType;

@interface ONOPacket : NSObject

@property(nonatomic) ONOPacketType type;
@property(nonatomic, strong) NSData *data;

- (instancetype)initWithType:(ONOPacketType)type andData:(NSData *)data;

@end
