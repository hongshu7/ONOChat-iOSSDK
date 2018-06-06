//
//  IMFriendRequestCell.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMFriendRequestCell.h"
#import "UIImageView+WebCache.h"
#import "ONOUser.h"

@interface IMFriendRequestCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;

@end

@implementation IMFriendRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFriendRequest:(ONOFriendRequest *)friendRequest {
    _friendRequest = friendRequest;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:friendRequest.user.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    self.nicknameLabel.text = friendRequest.user.nickname;
    
    self.greetingLabel.text = friendRequest.greeting;
}

- (IBAction)acceptAction {
    if(self.acceptDidClicked){
        self.acceptDidClicked(self.friendRequest);
    }
}
- (IBAction)ignoreAction {
    if(self.ignoreDidClicked){
        self.ignoreDidClicked(self.friendRequest);
    }
}

@end
