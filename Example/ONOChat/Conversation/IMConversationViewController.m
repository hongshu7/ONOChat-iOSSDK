//
//  IMSessionViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/25.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMConversationViewController.h"
#import "IMConversationCell.h"
#import "IMChatViewController.h"

#import "ONOIMClient.h"
#import "ONOTextMessage.h"


@interface IMConversationViewController ()

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IMConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"会话";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发起聊天" style:UIBarButtonItemStylePlain target:self action:@selector(starNewSession)];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加好友" style:UIBarButtonItemStylePlain target:self action:@selector(starNewSession)];
    
    
    // 模拟两个用户
//    userOne.token = @"ju9es1b7w6kproa32ghqvdt0xzmfycin";
//    userTwo.token = @"jkdlpx7830zuan4gr5o1f9sivmwbq2he";
// 7d98kx2b5qulfzgsv4ma3rjnhwic06p1    carrot3
    
    // iPhoneX
    self.dataArray = @[];
    [self loginToIMServerWithToken:@"ju9es1b7w6kproa32ghqvdt0xzmfycin"];
    
    // iPhone8P
//    self.dataArray = @[userOne];
//    [self LoginByUser:userTwo];
    self.dataArray = @[];

}

- (void)viewDidAppear:(BOOL)animated {
    self.dataArray = [[ONOIMClient sharedClient] getConversationList];
    [self.tableView reloadData];
}

- (void)loginToIMServerWithToken:(NSString *)token {
    [[ONOIMClient sharedClient] setupWithHost:@"101.201.236.225" port:3001];
    [[ONOIMClient sharedClient] loginWithToken:token onSuccess:^(ONOUser *user) {
        NSLog(@"user logined with name:%@", user.nickname);
        self.dataArray = [[ONOIMClient sharedClient] getConversationList];
        [self.tableView reloadData];
    } onError:^(int errorCode, NSString *errorMsg) {
        NSLog(@"user logined with error:%@", errorMsg);
    }];

}

- (void)starNewSession {
    //发起对carrot2的会话
    [[ONOIMClient sharedClient] userProfile:@"carrot2" withCache:NO onSuccess:^(ONOUser *user) {
        IMChatViewController *vc = [[IMChatViewController alloc] init];
        vc.toUserModel = user;
        [self.navigationController pushViewController:vc animated:YES];
    } onError:^(int errorCode, NSString *messageId) {
        
    }];

}

#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IMSessionViewCell";
    
    IMConversationCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([IMConversationCell class]) owner:nil options:nil] lastObject];
    }
    cell.conversation = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IMChatViewController *vc = [[IMChatViewController alloc] init];
    ONOConversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    vc.toUserModel = conversation.user;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
