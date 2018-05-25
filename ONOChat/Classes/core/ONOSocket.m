//
//  HUDManager.m
//  Mama
//
//  Created by Kevin Lai on 14-6-17.
//  Copyright (c) 2014年 rxwang. All rights reserved.
//

#import "ONOSocket.h"
#import "FastSocket.h"
#import "ONOMessage.h"
#import "ONOIMClient.h"

@interface ONOSocket ()

@property BOOL isStop;

@property (strong, nonatomic)NSString *host;
@property int port;
@property (strong, nonatomic)FastSocket *client;

@property dispatch_queue_t sendQueue;
@property int delayInSeconds;

@property dispatch_source_t timer;
@property int lastSendTime;

@end

@implementation ONOSocket



- (id)init
{
    if (self = [super init]) {
        const char *queueName = [[[NSDate date] description] UTF8String];
        self.sendQueue = dispatch_queue_create(queueName, NULL);
    }
    return self;
}

- (BOOL)isSetup
{
    return  self.host != nil;
}

- (void)setupWithHost:(NSString*)host port:(int)port
{
    self.host = host;
    self.port = port;
}

- (void)connect
{
    if (![self isSetup]) {
        return;
    }
    //start recive thread
    self.delayInSeconds = 3;
    [NSThread detachNewThreadSelector:@selector(connectBackground) toTarget:self withObject:nil];
}

- (void)close
{
    self.delayInSeconds = 0;
    if (self.isConnect) {
        [self.client close];
    }
}

- (void)connectBackground
{
    if (self.isConnect) {
        return;
    }
    NSLog(@"connectBackground");
    //连接
    self.client = [[FastSocket alloc] initWithHost:self.host andPort:[@(self.port) stringValue]];
    [self.client connect];
    NSLog(@"connectBackground 2");
    if (self.client.lastError != nil) {
        [self connectAfterAWhile];
        return;
    }
    
    self.isConnect = YES;
    self.isStop = NO;
    
    NSLog(@"connectBackground 3");
    //3秒后重新连接
    self.delayInSeconds = 3;
    
    //握手
    [self handshake];
    
    //开始接收数据
    while (!self.isStop) {
        [self reciveData];
    }
}

//握手
- (void)handshake
{
    NSString *str = @"{\"sys\":{\"type\":\"ios\",\"version\":\"1.0\",\"protocol\":\"protobuf\"}}";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    ONOPacket *packet = [[ONOPacket alloc] initWithType:IM_PT_HANDSHAKE andData:data];
    [self sendData:packet];
}

//心跳
- (void)heartBeat:(NSInteger)hbi
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), hbi * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        ONOPacket* mp = [[ONOPacket alloc] init];
        mp.type = IM_PT_HEARTBEAT;
        [self sendData:mp];
        //if (self.lastSendTime < [[NSDate date] timeIntervalSince1970] - 30.0) {
        //}

    });
    dispatch_resume(_timer);
}

- (void)stopHeartBeat
{
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)connectAfterAWhile
{
    self.isConnect = NO;
    self.isStop = YES;
    
    if (self.delayInSeconds == 0) {
        NSLog(@"no longer connect");
        return;
    } else {
        NSLog(@"connectAfter %d seconds", self.delayInSeconds);
    }
    dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, self.delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void)
    {
        NSLog(@"do connectBackground");
        [self connectBackground];
    });
    
    switch (self.delayInSeconds) {
        case 3:
            //15秒后重连
            self.delayInSeconds = 5;
            break;
        case 5:
            //15秒后重连
            self.delayInSeconds = 10;
            break;
        case 10:
            //15秒后重连
            self.delayInSeconds = 15;
            break;
        case 15:
            //20秒后重连
            self.delayInSeconds = 20;
            break;
        case 20:
            //30秒后重连
            self.delayInSeconds = 30;
            break;
        case 30:
            //60秒后重连
            self.delayInSeconds = 60;
            break;
        case 60:
            //2分钟后重连
            self.delayInSeconds = 120;
            break;
        case 120:
            //5分钟后重连
            self.delayInSeconds = 300;
            break;
        case 300:
            //10分钟后重连
            self.delayInSeconds = 600;
            break;
        case 600:
            //半小时后重连
            self.delayInSeconds = 1800;
            break;
        default:
            //不再重连了
            self.delayInSeconds = 0;
            break;
    }
}


- (void)sendData:(ONOPacket*)packet
{
    //发送队列，先进先出
    dispatch_async(self.sendQueue, ^{
        self.lastSendTime = [[NSDate date] timeIntervalSince1970];
        
        unsigned int length = (int)[packet.data length];

        char bytes[4 + length];
        bytes[0] = packet.type & 0xff;
        bytes[1] = (length >> 16) & 0xff;
        bytes[2] = (length >> 8) & 0xff;
        bytes[3] = length & 0xff;
        
        if (length > 0) {
            const char* data = [packet.data bytes];
            strncpy(&(bytes[4]), data, length);
            //free((void *)data);
        }
        
        NSLog(@"write type:%d, length:%d", packet.type, length + 4);
        [self.client sendBytes:(void*)bytes count:length + 4];

    });
}

- (void)reciveData
{
    unsigned char headers[4];
    BOOL isReceived = [self.client receiveBytes:&headers count:4];
    if (!isReceived || self.client.lastError != nil) {
        NSLog(@"revice head fail");
        [self stopHeartBeat];
        [self connectAfterAWhile];
        return;
    }
    
    //解析头部信息
    ONOPacketType type = (ONOPacketType) headers[0];
    unsigned int length = ((headers[1]) << 16 | (headers[2]) << 8 | headers[3]) >> 0;
    
    NSLog(@"headers: %d,%d,%d,%d", headers[0], headers[1], headers[2], headers[3]);
    
    ONOPacket* packet = [[ONOPacket alloc] init];
    packet.type = type;
    NSLog(@"revice type:%d, length:%d", type, length);
    
    if (length > 0) {
        char bytes[length];
        isReceived = [self.client receiveBytes:bytes count:length];
        if (!isReceived || self.client.lastError != nil) {
            NSLog(@"revice body fail");
            [self stopHeartBeat];
            [self connectAfterAWhile];
            return;
        }
        
        packet.data = [NSData dataWithBytes:bytes length:length];

        NSLog(@"revice msg type:%zd", packet.type);
        
    }
    NSLog(@"dispatch packet");
    if (packet.type == IM_PT_HANDSHAKE) {
        //服务端握手回应
        [[ONOIMClient sharedClient] handleConnected:packet.data];
    } else if (packet.type == IM_PT_DATA) {
        //消息包
        ONOMessage *message = [[ONOMessage alloc] init];
        [message decode:packet.data];
        [self performSelectorOnMainThread:@selector(dispatchMessage:) withObject:message waitUntilDone:NO];
    }
    
}

- (void)dispatchMessage:(id)message
{
    NSLog(@"get packet:%@", message);
    [[ONOIMClient sharedClient] handleResponse:message];
}

@end