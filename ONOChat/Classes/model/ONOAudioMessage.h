//
//  ONOAudioMessage.h
//  ONOChat
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOBaseMessage.h"

@interface ONOAudioMessage : ONOBaseMessage

@property (nonatomic, strong) NSString *audio;
@property (nonatomic, assign) int duration;

@end
