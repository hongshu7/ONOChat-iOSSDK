//
//  IMChatModel.h
//  UUChatTableView
//
//  Created by carrot__lsp on 2018/5/22.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UUMessageFrame;
@interface IMChatModel : NSObject

@property (nonatomic, strong) NSMutableArray<UUMessageFrame *> *dataSource;

@property (nonatomic) BOOL isGroupChat;

- (void)populateRandomDataSource;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addSpecifiedItem:(NSDictionary *)dic;

- (void)recountFrame;

@end
