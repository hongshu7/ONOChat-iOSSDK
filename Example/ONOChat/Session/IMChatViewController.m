//
//  IMChatViewController.m
//  UUChatTableView
//
//  Created by carrot__lsp on 2018/5/22.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "IMChatViewController.h"
#import "UUInputFunctionView.h"
#import "UUMessageCell.h"
#import "IMChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import <MJRefresh/MJRefresh.h>
#import "UUChatCategory.h"
#import "IMGlobalData.h"
#import "IMChatManager.h"
#import "IMToast.h"

#import "ONOIMClient.h"
#import "ONOTextMessage.h"

@interface IMChatViewController ()<UUInputFunctionViewDelegate, UUMessageCellDelegate, UITableViewDataSource, UITableViewDelegate,ONOReceiveMessageDelegate,IMReceiveMessageDelegate>
{
	CGFloat _keyboardHeight;
}
@property (strong, nonatomic) IMChatModel *chatModel;

@property (strong, nonatomic) UITableView *chatTableView;

@property (strong, nonatomic) UUInputFunctionView *inputFuncView;

@end

@implementation IMChatViewController

#pragma mark - life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBasicViews];
    [self addRefreshViews];
    [self loadBaseViewsAndData];
	_chatTableView.frame = CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40);
	_inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
//
//    [ONOIMClient sharedClient].receiveMessageDelegate = self;
    __weak typeof(self) weakSelf = self;
    [[ONOIMClient sharedClient] userProfile:self.targetId onSuccess:^(ONOUser *user) {
        weakSelf.navigationItem.title = user.nickname;
    } onError:^(int errorCode, NSString *errorMessage) {
        [IMToast showTipMessage:errorMessage];
    }];
    
    
    [[IMChatManager sharedChatManager] addReceiveMessageDelegate:self];
    
    [[ONOIMClient sharedClient] clearConversationUnread:self.targetId];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustCollectionViewLayout) name:UIDeviceOrientationDidChangeNotification object:nil];
	[self tableViewScrollToBottom];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	if (_inputFuncView.textViewInput.isFirstResponder) {
		_chatTableView.frame = CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40-_keyboardHeight);
		_inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
	} else {
		_chatTableView.frame = CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40);
		_inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
	}
}

- (void)dealloc {
    [[IMChatManager sharedChatManager] removeReceiveMessageDelegate:self];
}

#pragma mark - ONOReceiveMessageDelegate
- (void)onReceived:(ONOMessage *)message {
    
    if (message.type == 1) {
        ONOTextMessage *textMessage = (ONOTextMessage *)message;
        __weak typeof(self) weakSelf = self;
        [[ONOIMClient sharedClient] userProfile:message.userId onSuccess:^(ONOUser *fromUser) {
            NSDictionary *dic = @{
                                  @"strContent": textMessage.text,
                                  @"type": @(UUMessageTypeText),
                                  @"strIcon": fromUser.avatar,
                                  @"strName": fromUser.nickname,
                                  };
            [weakSelf.chatModel addOtherChatItem:dic];
            [weakSelf.chatTableView reloadData];
            [weakSelf tableViewScrollToBottom];
        } onError:^(int errorCode, NSString *errorMessage) {
            
        }];
        [[ONOIMClient sharedClient] clearConversationUnread:self.targetId];
    } else {
        
    }
    
//    [dataDic setObject:@"Hi:sister" forKey:@"strName"];
//    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    
    
//    addOtherChatItem
}

#pragma mark - prive methods

- (void)initBasicViews
{
	_chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40) style:UITableViewStylePlain];
	_chatTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_chatTableView.delegate = self;
	_chatTableView.dataSource = self;
	[self.view addSubview:_chatTableView];
	
	[_chatTableView registerClass:[UUMessageCell class] forCellReuseIdentifier:NSStringFromClass([UUMessageCell class])];
	
	_inputFuncView = [[UUInputFunctionView alloc] initWithFrame:CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40)];
	_inputFuncView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	_inputFuncView.delegate = self;
	[self.view addSubview:_inputFuncView];
	
	
	
//    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@" private ",@" group "]];
//    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
//    segment.selectedSegmentIndex = 0;
//    self.navigationItem.titleView = segment;
//
//    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:nil action:nil];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:nil action:nil];
}

- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    //load more
	self.chatTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
		
		int count = [weakSelf.chatModel loadRecordMessageData];
		
		if (weakSelf.chatModel.dataSource.count > count) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[weakSelf.chatTableView reloadData];
				[weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
			});
		}
		[weakSelf.chatTableView.mj_header endRefreshing];
	}];
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[IMChatModel alloc] init];
    self.chatModel.isGroupChat = NO;
    /**  */
    self.chatModel.targetId = self.targetId;
    [self.chatModel loadRecordMessageData];
	
    [self.chatTableView reloadData];
}

- (void)segmentChanged:(UISegmentedControl *)segment
{
	self.chatModel.isGroupChat = segment.selectedSegmentIndex;
	[self.chatModel.dataSource removeAllObjects];
	[self.chatModel loadRecordMessageData];
	[self.chatTableView reloadData];
}

#pragma mark - notification event

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
	if (self.chatModel.dataSource.count==0) { return; }
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
	[self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	_keyboardHeight = keyboardEndFrame.size.height;
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	
	self.chatTableView.uu_height = self.view.uu_height - _inputFuncView.uu_height;
	self.chatTableView.uu_height -= notification.name == UIKeyboardWillShowNotification ? _keyboardHeight:0;
	self.chatTableView.contentOffset = CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.uu_height);

	self.inputFuncView.uu_top = self.chatTableView.uu_bottom;
	
    [UIView commitAnimations];
}

- (void)adjustCollectionViewLayout
{
	[self.chatModel recountFrame];
	[self.chatTableView reloadData];
}

#pragma mark - InputFunctionViewDelegate

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    ONOUser *user = [IMGlobalData sharedData].user;
    NSDictionary *dic = @{
                          @"strContent": message,
                          @"type": @(UUMessageTypeText),
                          @"strIcon": user.avatar,
                          @"strName": user.nickname,
                          };
    funcView.textViewInput.text = @"";
//    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
    
    ONOTextMessage *msg = [[ONOTextMessage alloc] init];
    msg.text = message;
    
    [[ONOIMClient sharedClient] sendMessage:msg to:self.targetId onSuccess:^(NSString *messageId) {
        NSLog(@"send ok");
    } onError:^(int errorCode, NSString *messageId) {
        NSLog(@"send failure");
    }];

}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addMyChatItem:dic];
    [self.chatTableView reloadData];
	[self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UUMessageCell class])];
	cell.delegate = self;
	cell.messageFrame = self.chatModel.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UUMessageCellDelegate

- (void)chatCell:(UUMessageCell *)cell headImageDidClick:(NSString *)userId
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

@end
