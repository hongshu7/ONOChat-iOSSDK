//  Lemeng
//
//  Created by Kevin Lai on 14-8-20.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import "IMMessage.h"
#import "IMClient.h"

#define MSG_COMPRESS_GZIP_MASK 0x1;
#define MSG_TYPE_MASK 0x7;
#define MSG_ERROR_MASK 0x1;

@implementation IMMessage

- (NSData *)encode {
    
    int headHength = 2; //flag + route
    if (self.type == IM_MT_REQUEST) {
        //msgid
        headHength += [IMMessage caculateMsgIdBytes:self.messageId];
    }
    
    char headBytes[headHength];
    //执行request
    BOOL compressGzip = false;
    //flag
    NSUInteger offset = 0;
    headBytes[offset++] = (self.type << 1) | (compressGzip ? 1 : 0);
    if (self.type == IM_MT_REQUEST) {
        //写入message id
        offset = [IMMessage encodeMsgId:self.messageId andBuffer:headBytes andOffset:offset];
    }
    IMRouteInfo *routeInfo = [[IMClient sharedInstance] getRouteInfo:self.route];
    headBytes[offset++] = routeInfo.routeId;
    NSLog(@"encode type:%d, route:%@, routeid:%zd, msgid:%zd", self.type, self.route, routeInfo.routeId, self.messageId);
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:headBytes length:headHength];
    
    if (self.message) {
        NSData *msgData = self.message.data;
        if (msgData) {
            [data appendData:msgData];
        }
    }
    return data;
}

- (void)decode:(NSData *)data {
    const char *bytes = [data bytes];
    int length = (int)[data length];
    int offset = 0;
    int flag = bytes[offset++];
    int compressGzip = flag & MSG_COMPRESS_GZIP_MASK;
    self.type = (flag >> 1) & MSG_TYPE_MASK;
    self.isError = (flag >> 4) & MSG_ERROR_MASK;
    NSLog(@"decode length:%d, gzip:%d, type:%d, error:%d", length, compressGzip, self.type, self.isError);
    
    if (self.type == IM_MT_RESPONSE) {
        //messageId += (m & 0x7f) << (7 * i);
        NSUInteger msgId = 0;
        unsigned char m = 0;
        int i = 0;
        do {
            m = bytes[offset];
            msgId = msgId +((m & 0x7f) * pow(2, 7 * i));
            offset++;
            i++;
        } while(m >= 128);
        //消息id
        self.messageId = msgId;
        self.route = [[IMClient sharedInstance] getRouteByMsgId:self.messageId];
        
    } else if (self.type == IM_MT_PUSH) {
        //解析route
        int routeId = bytes[offset++];
        self.route = [[IMClient sharedInstance] getRouteByRouteId:routeId];
    }
    NSLog(@"decode messageId:%zd, route:%@, body length:%d", self.messageId, self.route, length - offset);
    NSData *body = [NSData dataWithBytes:&(bytes[offset]) length:length - offset];
    //free((void *)bytes);
    
    //解析内容
    if (self.isError) {
        self.message = [ErrorResponse parseFromData:body error:nil];
    } else {
        IMRouteInfo *routeInfo = [[IMClient sharedInstance] getRouteInfo:self.route];
        //push将使用resuest
        NSString *messageName = self.type == IM_MT_RESPONSE ? routeInfo.response : routeInfo.request;
//        if (self.type == IM_MT_PUSH) {
//            NSLog(@"%@", body);
//            Comment *comment = [[[[[Comment builder] setUserId:10000088] setNickname:@"张三"] setContent:@"你好，朋友!"] build];
//            CommentPush *data = [[[CommentPush builder] setComment:comment] build];
//            NSLog(@"%@", [data data]);
//        }
        if (messageName) {
            NSLog(@"message name:%@", messageName);
            
            Class class = NSClassFromString(messageName);
            NSError *error = nil;
            self.message = [class parseFromData:body error:&error];
            if (error != nil) {
                self.message = nil;
            }
        } else {
            self.message = nil;
        }
    }

}


+ (NSUInteger)encodeMsgId:(NSInteger)msgId
                      andBuffer:(char *)buffer
                      andOffset:(NSUInteger)offset {
    NSUInteger tmpOffset = offset;
    NSInteger tmpMsgId = msgId;
    do {
        NSInteger tmp = tmpMsgId % 128;
        NSInteger next = tmpMsgId /128;
        if (next != 0) {
            tmp += 128;
        }
        buffer[tmpOffset++] = tmp;
        tmpMsgId = next;
    } while (tmpMsgId != 0);
    
    return tmpOffset;
    
}

+ (NSUInteger)caculateMsgIdBytes:(NSInteger)msgId {
    NSUInteger len = 0;
    do {
        len += 1;
        msgId >>= 7;
    } while (msgId > 0);
    return len;
}



@end
