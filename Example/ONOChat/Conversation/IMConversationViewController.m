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
#import "UINavigationController+IM.h"
#import "IMGlobalData.h"
#import "IMChatManager.h"

#import "ONOIMClient.h"
#import "ONOTextMessage.h"


@interface IMConversationViewController ()<IMReceiveMessageDelegate>

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IMConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发起聊天" style:UIBarButtonItemStylePlain target:self action:@selector(starNewSession)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logoutAction)];
    
    
    [[IMChatManager sharedChatManager] statListenOtherMessage];
    [[IMChatManager sharedChatManager] addReceiveMessageDelegate:self];
    [self updateTabbarBadge];
    self.navigationItem.title = [IMGlobalData sharedData].user.nickname;
    
    self.dataArray = @[];
    
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = [[ONOIMClient sharedClient] getConversationList];
    [self.tableView reloadData];
    [self updateTabbarBadge];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[IMChatManager sharedChatManager] removeReceiveMessageDelegate:self];
}

- (void)logoutAction{
    [[IMGlobalData sharedData] logout];
}



- (void)updateTabbarBadge {
    int count = [[ONOIMClient sharedClient] totalUnreadCount];
    if (count > 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",count];
    } else {
        self.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - ONOReceiveMessageDelegate
- (void)onReceived:(ONOMessage *)message {
    self.dataArray = [[ONOIMClient sharedClient] getConversationList];
    [self.tableView reloadData];
    [self updateTabbarBadge];
}

- (void)onGetUnreadMessages {
    self.dataArray = [[ONOIMClient sharedClient] getConversationList];
    [self.tableView reloadData];
    [self updateTabbarBadge];
}

//- (void)starNewSession {
//    // iPhoneX
//    // @"ju9es1b7w6kproa32ghqvdt0xzmfycin";     carrot
//
//    // iPhone8P
//    // @"jkdlpx7830zuan4gr5o1f9sivmwbq2he";     carrot2
//
//    NSString *userId = @"";
//    if (iPhoneX) {
//        userId = @"carrot";
//    } else {
//        userId = @"carrot2";
//    }
//
//
//    //发起对carrot2的会话
//    [[ONOIMClient sharedClient] userProfile:userId withCache:NO onSuccess:^(ONOUser *user) {
//        IMChatViewController *vc = [[IMChatViewController alloc] init];
//        vc.targetId = user.userId;
//        [self.navigationController im_pushViewController:vc];
//    } onError:^(int errorCode, NSString *messageId) {
//
//    }];
//
//}

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
    vc.targetId = conversation.user.userId;
    [self.navigationController im_pushViewController:vc ];
}


@end
