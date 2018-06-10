//
//  IMLoginCell.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/10.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMLoginCell.h"
#import "UIImageView+WebCache.h"

@interface IMLoginCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@end

@implementation IMLoginCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLoginModel:(IMLoginModel *)loginModel {
    _loginModel = loginModel;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:loginModel.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    self.nicknameLabel.text = loginModel.nickname;
}

@end
