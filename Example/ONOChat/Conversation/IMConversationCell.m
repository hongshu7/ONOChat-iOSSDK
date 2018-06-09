//
//  IMSessionViewCell.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/25.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMConversationCell.h"
#import "UIImageView+WebCache.h"
#import "ONOTextMessage.h"

@interface IMConversationCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

@end

@implementation IMConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setConversation:(ONOConversation *)conversation {
    _conversation = conversation;
    self.nicknameLabel.text = conversation.user.nickname;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:conversation.user.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    
    if (conversation.lastMessage != nil && conversation.lastMessage.type == 1) {
        ONOTextMessage *textMessage = (ONOTextMessage*)conversation.lastMessage;
        self.lastMessageLabel.text = [NSString stringWithFormat:@"%@：%@",textMessage.user.nickname,textMessage.text];
    } else {
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
