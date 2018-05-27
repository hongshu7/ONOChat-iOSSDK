//
//  ONOMessage.h
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import <Foundation/Foundation.h>
#import "ONOUser.h"

@interface ONOMessage : NSObject

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) ONOUser *user;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) BOOL isError;

- (NSInteger)type;
- (NSString *)encode;
- (void)decode:(NSString *)data;

@end
