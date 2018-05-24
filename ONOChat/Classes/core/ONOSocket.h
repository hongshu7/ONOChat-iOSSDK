//
//  HUDManager.h
//  Mama
//
//  Created by Kevin Lai on 14-6-17.
//  Copyright (c) 2014年 rxwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONOPacket.h"

@interface ONOSocket : NSObject

@property BOOL isConnect;

- (void)setupWithHost:(NSString*)host port:(int)port;

- (void)connect;
- (void)close;

- (void)heartBeat:(NSInteger)hbi;

- (void)sendData:(ONOPacket*)message;

@end
