//
//  ONOBaseMessage.h
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import <Foundation/Foundation.h>

typedef enum _ConversationType {
    ConversationTypePrivate  = 1,
    ConversationTypeGroup,
} ConversationType;

@interface ONOBaseMessage : NSObject

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, assign) NSInteger timestamp;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *data;

@end
