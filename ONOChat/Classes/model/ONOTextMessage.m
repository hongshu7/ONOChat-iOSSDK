//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
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
