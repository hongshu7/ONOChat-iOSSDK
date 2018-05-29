//
//  IMContactViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/28.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMContactViewController.h"
#import "IMConversationCell.h"
#import "IMChatViewController.h"
#import "IMAddNewFriendViewController.h"
#import "UINavigationController+IM.h"

#import "ONOIMClient.h"


@interface IMContactViewController ()

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IMContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"通讯录";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+好友" style:UIBarButtonItemStylePlain target:self action:@selector(addNewFriend)];
}


- (void)addNewFriend {
    [self.navigationController im_pushViewController:[IMAddNewFriendViewController new]];
}

- (void)viewDidAppear:(BOOL)animated {
    self.dataArray = [[ONOIMClient sharedClient] getConversationList];
    [self.tableView reloadData];
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
    [self.navigationController im_pushViewController:vc];
}


@end
