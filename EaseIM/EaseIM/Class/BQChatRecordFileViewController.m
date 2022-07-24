//
//  BQChatRecordFileViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordFileViewController.h"
#import "EMDateHelper.h"
#import "EMChatViewController.h"
#import "BQChatRecordFileModel.h"
#import "BQChatRecordFileCell.h"
#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"
#import "BQNoDataPlaceHolderView.h"

@interface BQChatRecordFileViewController ()<UITableViewDelegate,UITableViewDataSource,EMSearchBarDelegate,MISScrollPageControllerContentSubViewControllerDelegate>

@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSString *moreMsgId;

//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;
@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) BQNoDataPlaceHolderView *noDataPromptView;

@end

@implementation BQChatRecordFileViewController

- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        _msgQueue = dispatch_queue_create("emmessagerecord.com", NULL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgTimelTag = -1;
    [self _setupChatSubviews];

    [self loadDatas];
}

- (void)loadDatas {
    
    if ([EMDemoOptions sharedOptions].isPriorityGetMsgFromServer) {
        EMConversation *conversation = self.conversation;
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
            [self.conversation loadMessagesStartFromId:self.moreMsgId count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
                [self loadMessages:aMessages withError:aError];
            }];
         }];
    } else {
        [self.conversation loadMessagesStartFromId:self.moreMsgId count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
            [self loadMessages:aMessages withError:aError];
        }];
    }
}

- (void)loadMessages:(NSArray *)aMessages  withError:(EMError *)aError {
    if (!aError && [aMessages count] > 0) {
        dispatch_async(self.msgQueue, ^{
            NSMutableArray *msgArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [aMessages count]; i++) {
                EMChatMessage *msg = aMessages[i];
                if(msg.body.type == EMMessageTypeFile) {
                    [msgArray addObject:msg];
                }
            }
            
            NSLog(@"%s msgArray:%@",__func__,msgArray);
            NSArray *formated = [self _formatMessages:[msgArray copy]];

            BQ_WS
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:formated];
                [weakSelf.tableView reloadData];
            });
        });
    }
    
}


#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItem];
    self.title = NSLocalizedString(@"msgList", nil);
    
if ([EMDemoOptions sharedOptions].isJiHuApp) {
    self.view.backgroundColor = ViewBgBlackColor;
    self.tableView.backgroundColor = ViewBgBlackColor;
}else {
    self.view.backgroundColor = ViewBgWhiteColor;
    self.tableView.backgroundColor = ViewBgWhiteColor;
}

    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(48.0));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(60.0);
        make.centerX.left.right.equalTo(self.view);
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return [self.searchResultArray count];
    }
    return [self.dataArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BQChatRecordFileCell *cell = (BQChatRecordFileCell *)[tableView dequeueReusableCellWithIdentifier:@"chatRecord"];

    if (cell == nil) {
        cell = [[BQChatRecordFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatRecord"];
    }
    
    id obj = nil;
    if (self.isSearching) {
        obj = [self.searchResultArray objectAtIndex:indexPath.row];
    }else {
        obj = [self.dataArray objectAtIndex:indexPath.row];
    }
    
    BQChatRecordFileModel *model = (BQChatRecordFileModel *)obj;
    cell.indexPath = indexPath;
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = nil;
    if (self.isSearching) {
        obj = [self.searchResultArray objectAtIndex:indexPath.row];
    }else {
        obj = [self.dataArray objectAtIndex:indexPath.row];
    }
    
    BQChatRecordFileModel *model = (BQChatRecordFileModel *)obj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSearchFileMessage:)]) {
        [self.delegate didTapSearchFileMessage:model.message];
    }
    
}

#pragma mark - BQChatRecordFileCellDelegate
- (void)cellAccessoryButtonAction:(BQChatRecordFileCell *)aCell
{
    EMChatViewController *chatController = [[EMChatViewController alloc]initWithConversationId:self.conversation.conversationId conversationType:self.conversation.type];
    chatController.modalPresentationStyle = 0;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - EMSearchBarDelegate

//- (void)searchBarSearchButtonClicked:(NSString *)aString
//{
//    _keyWord = aString;
//    [self.view endEditing:YES];
//    if ([_keyWord length] < 1)
//        return;
//    if (!self.isSearching) return;
//
//    __weak typeof(self) weakself = self;
//    [self.conversation loadMessagesWithKeyword:aString timestamp:0 count:100 fromUser:nil searchDirection:EMMessageSearchDirectionDown completion:^(NSArray *aMessages, EMError *aError) {
//        if (!aError && [aMessages count] > 0) {
//            dispatch_async(self.msgQueue, ^{
//                NSMutableArray *msgArray = [[NSMutableArray alloc] init];
//                for (int i = 0; i < [aMessages count]; i++) {
//                    EMChatMessage *msg = aMessages[i];
//                    if(msg.body.type == EMMessageBodyTypeFile) {
//                        EMFileMessageBody* fileBody = (EMFileMessageBody*)msg.body;
//                        NSRange range = [fileBody.displayName rangeOfString:aString options:NSCaseInsensitiveSearch];
//                        if(range.length)
//                            [msgArray addObject:msg];
//                    }
//
//                }
//                NSArray *formated = [weakself _formatMessages:[msgArray copy]];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    weakself.noDataPromptView.hidden = YES;
//                    [weakself.searchResults removeAllObjects];
//                    [weakself.searchResults addObjectsFromArray:formated];
//                    [weakself.searchResultTableView reloadData];
//                });
//            });
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakself.noDataPromptView.hidden = NO;
//                [weakself.searchResults removeAllObjects];
//                [weakself.searchResultTableView reloadData];
//            });
//        }
//    }];
//}

#pragma mark - EMSearchBarDelegate

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    if (!self.isSearching) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.isSearching = YES;
    }
}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    self.isSearching = NO;
    
    self.noDataPromptView.hidden = YES;
    [self.searchResultArray removeAllObjects];
    [self.tableView reloadData];
    
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    if (!self.isSearching) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(filename) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.noDataPromptView.hidden = results.count > 0? YES: NO;
            [weakself.searchResultArray removeAllObjects];
            [weakself.searchResultArray addObjectsFromArray:results];
            [weakself.tableView reloadData];
        });
    }];
        
}



#pragma mark - Data

- (NSArray *)_formatMessages:(NSArray<EMChatMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    NSString *timeStr;
    for (int i = 0; i < [aMessages count]; i++) {
        EMChatMessage *msg = aMessages[i];
        if (!(msg.body.type == EMMessageBodyTypeFile))
            continue;
        if ([msg.ext objectForKey:MSG_EXT_GIF] || [msg.ext objectForKey:MSG_EXT_RECALL] || [msg.ext objectForKey:MSG_EXT_NEWNOTI])
            continue;
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            self.msgTimelTag = msg.timestamp;
        }
        
        BQChatRecordFileModel *model = [[BQChatRecordFileModel alloc]initWithMessage:msg time:timeStr];
        [formated addObject:model];
    }
    
    return formated;
}


#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[BQChatRecordFileCell class] forCellReuseIdentifier:NSStringFromClass([BQChatRecordFileCell class])];
    }
    return _tableView;
}


- (NSMutableArray *)searchResultArray {
    if (_searchResultArray == nil) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (BQNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = BQNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"ji_search_nodata")];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}



#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}


@end
