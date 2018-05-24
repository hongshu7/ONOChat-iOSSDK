//
//  ONOTextMessage.m
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOTextMessage.h"

@implementation ONOTextMessage

- (NSInteger)type {
    return 1;
}

- (NSString *)content {
    return self.text;
}

- (NSString *)data {
    return @"";
}

@end
