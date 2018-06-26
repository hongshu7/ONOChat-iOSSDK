//
//  IMContactViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/28.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMContactViewController.h"
#import "IMContactCell.h"
#import "IMChatViewController.h"
#import "IMAddNewFriendViewController.h"
#import "UINavigationController+IM.h"
#import "IMFriendRequestListViewController.h"
#import "IMToast.h"
#import "UIView+Extension.h"
#import "IMChatManager.h"

#import "ONOIMClient.h"


@interface IMContactViewController ()<IMReceiveFriendMessageDelegate>

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IMContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"通讯录";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+好友" style:UIBarButtonItemStylePlain target:self action:@selector(addNewFriend)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"好友请求列表" style:UIBarButtonItemStylePlain target:self action:@selector(newFriendList)];
    
    [IMChatManager sharedChatManager].receiveFriendMessageDelegate = self;
}

- (void)dealloc {
    [IMChatManager sharedChatManager].receiveFriendMessageDelegate = nil;
}

- (void)onReceivedFriendListUpdate {
    self.dataArray = [[ONOIMClient sharedClient] getFriends];
    [self.tableView reloadData];
}

- (void)newFriendList {
    [self.navigationController im_pushViewController:[IMFriendRequestListViewController new]];
}
- (void)addNewFriend {
    [self.navigationController im_pushViewController:[IMAddNewFriendViewController new]];
}

- (void)viewDidAppear:(BOOL)animated {
    self.dataArray = [[ONOIMClient sharedClient] getFriends];
    [self.tableView reloadData];
}

#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IMContactCell";
    
    IMContactCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [IMContactCell im_loadFromXIB];
    }
    cell.user = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
        // 添加一个删除按钮
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                   {
                       ONOUser *user = [weakSelf.dataArray objectAtIndex:indexPath.row];
                       [[ONOIMClient sharedClient] friendDeleteWithUserId:user.userId onSuccess:^{
                           [IMToast showTipMessage:@"删除成功"];
                           weakSelf.dataArray = [[ONOIMClient sharedClient] getFriends];
                           [weakSelf.tableView reloadData];
                       } onError:^(int errorCode, NSString *errorMessage) {
                           [IMToast showTipMessage:errorMessage];
                       }];
                   }];

    return @[deleteRowAction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IMChatViewController *vc = [[IMChatViewController alloc] init];
    ONOUser *user = [self.dataArray objectAtIndex:indexPath.row];
    vc.targetId = user.userId;
    [self.navigationController im_pushViewController:vc];
}


@end
