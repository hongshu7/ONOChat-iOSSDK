//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOPacket.h"

@interface ONOSocket : NSObject

@property BOOL isConnect;

- (void)setupGateHost:(NSString*)host port:(int)port;

- (void)connect;
- (void)close;

- (void)heartBeat:(NSInteger)hbi;

- (void)sendData:(ONOPacket*)message;

@end
