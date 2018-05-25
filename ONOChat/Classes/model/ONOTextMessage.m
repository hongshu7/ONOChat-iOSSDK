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

- (NSString *)encode {
    return self.text;
}

- (void)decode:(NSString *)data {
    self.text = data;
}

- (NSString *)description {
    return self.text;
}

@end
