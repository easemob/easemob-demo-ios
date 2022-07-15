//
//  ConfInviteUsersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "ConfInviteUsersViewController.h"

#import "EMRealtimeSearch.h"
#import "ConferenceController.h"
#import "ConfInviteUserCell.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "BQConfInviteSelectedUsersView.h"

@interface ConfInviteUsersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIView *customNavBarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic) BOOL isCreate;
@property (nonatomic) ConfInviteType type;
@property (nonatomic, strong) NSArray *excludeUsers;
@property (nonatomic, strong) NSString *gorcId;

@property (nonatomic, strong) NSString *cursor;
@property (nonatomic) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
@property (nonatomic, strong) NSMutableArray *inviteUsers;

@property (nonatomic, strong) BQConfInviteSelectedUsersView *confInviteSelectedUsersView;


@end



@implementation ConfInviteUsersViewController

- (instancetype)initWithType:(ConfInviteType)aType
                    isCreate:(BOOL)aIsCreate
                excludeUsers:(NSArray *)aExcludeUsers
           groupOrChatroomId:(NSString *)aGorcId
{
    self = [super init];
    if (self) {
        _type = aType;
        _isCreate = aIsCreate;
        _excludeUsers = aExcludeUsers;
        _gorcId = aGorcId;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchDataArray = [[NSMutableArray alloc] init];
    self.inviteUsers = [[NSMutableArray alloc] init];
    
    if (self.isCreate) {
        self.titleLabel.text = @"选择成员";
    }else {
        self.titleLabel.text = @"添加成员";
    }
    
    [self _setupSubviews];
    
    self.showRefreshHeader = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
}

#pragma mark - Subviews

//- (void)_setupSubviews
//{
//    self.view.backgroundColor = [UIColor whiteColor];
//
//    self.titleLabel = [[UILabel alloc] init];
//    self.titleLabel.textColor = [UIColor blackColor];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.titleLabel.font = [UIFont systemFontOfSize:18];
//    self.titleLabel.text = NSLocalizedString(@"invite", nil);
//    [self.view addSubview:self.titleLabel];
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(45);
//        make.right.equalTo(self.view).offset(-45);
//        make.top.equalTo(self.view).offset(20 + EMVIEWTOPMARGIN);
//        make.height.equalTo(@45);
//    }];
//
//    UIButton *closeButton = [[UIButton alloc] init];
//    closeButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    [closeButton setTitle:NSLocalizedString(@"close", nil) forState:UIControlStateNormal];
//    [closeButton setTitleColor:[UIColor colorWithRed:8 / 255.0 green:115 / 255.0 blue:222 / 255.0 alpha:1.0] forState:UIControlStateNormal];
//    [closeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:closeButton];
//    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        //make.left.equalTo(self.titleLabel.mas_right);
//        make.right.equalTo(self.view).offset(-10);
//        make.top.equalTo(self.titleLabel);
//        make.bottom.equalTo(self.titleLabel);
//    }];
//
//    self.searchBar = [[UISearchBar alloc] init];
//    self.searchBar.delegate = self;
//    self.searchBar.barTintColor = [UIColor whiteColor];
//    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
//    CGFloat color = 245 / 255.0;
//    searchField.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
//    self.searchBar.placeholder = NSLocalizedString(@"serchContact", nil);
//    [self.view addSubview:self.searchBar];
//    [self.view sendSubviewToBack:self.searchBar];
//    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
//        make.left.equalTo(self.view).offset(10);
//        make.right.equalTo(self.view).offset(-10);
//    }];
//
//    UIButton *startButton = [[UIButton alloc] init];
//    startButton.layer.cornerRadius = 24;
//    startButton.layer.shadowColor = [UIColor grayColor].CGColor;
//    startButton.layer.shadowOpacity = 0.8f;
//    startButton.layer.shadowRadius = 4.0f;
//    startButton.layer.shadowOffset = CGSizeMake(0, 0);
//    startButton.backgroundColor = [UIColor colorWithRed:20 / 255.0 green:137 / 255.0 blue:71 / 255.0 alpha:1.0];
//    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [startButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
//    if (self.isCreate) {
//        [startButton setTitle:NSLocalizedString(@"start Comminucation", nil) forState:UIControlStateNormal];
//    } else {
//        [startButton setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
//    }
//    [startButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:startButton];
//    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-36);
//        make.left.equalTo(self.view).offset(36);
//        make.right.equalTo(self.view).offset(-36);
//        make.height.equalTo(@48);
//    }];
//
//    self.searchTableView = [[UITableView alloc] init];
//    self.searchTableView.delegate = self;
//    self.searchTableView.dataSource = self;
//    self.searchTableView.rowHeight = 60;
//
//    self.tableView.rowHeight = 60;
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.searchBar.mas_bottom);
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.bottom.equalTo(startButton.mas_top).offset(-20);
//    }];
//
//    UINib *nib = [UINib nibWithNibName:@"ConfInviteUserCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
//    [self.searchTableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
//}

- (void)_setupSubviews {

    [self.view addSubview:self.customNavBarView];
    [self.view addSubview:self.confInviteSelectedUsersView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];


    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(48.0));
    }];

    
    [self.confInviteSelectedUsersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.left.right.equalTo(self.view);
//        make.height.equalTo(@(70.0));
        make.height.equalTo(@(0));
    }];
    
    
    [self.view sendSubviewToBack:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confInviteSelectedUsersView.mas_bottom).offset(8.0);
        make.left.equalTo(self.view).offset(16.0);
        make.right.equalTo(self.view).offset(-16.0);
        make.height.equalTo(@(32.0));
    }];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(8.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    
    self.tableView.rowHeight = 64.0;
    UINib *nib = [UINib nibWithNibName:@"ConfInviteUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
    [self.searchTableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchDataArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConfInviteUserCell";
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    
    [cell updateWithObj:username];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.inviteUsers containsObject:username];
    if (isChecked) {
        [self.inviteUsers removeObject:username];
    } else {
        [self.inviteUsers addObject:username];
    }
    cell.isChecked = !isChecked;
    
    [self updateUI];
}

- (void)updateUI {
    
    CGFloat inviteHeight = self.inviteUsers.count > 0 ? 70 : 0;
    [self.confInviteSelectedUsersView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(inviteHeight));
    }];
    
    NSString *confirmTitle = [NSString stringWithFormat:@"确定(%@)",@([self.inviteUsers count])];
    [self.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    
    [self.confInviteSelectedUsersView updateUIWithMemberArray:self.inviteUsers];
    
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!self.isSearching) {
        self.isSearching = YES;
        [self.view addSubview:self.searchTableView];
        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView);
            make.left.equalTo(self.tableView);
            make.right.equalTo(self.tableView);
            make.bottom.equalTo(self.tableView);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:searchBar.text collationStringSelector:nil resultBlock:^(NSArray *results) {
        if ([results count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchDataArray removeAllObjects];
                [weakSelf.searchDataArray addObjectsFromArray:results];
                [self.searchTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];

        return NO;
    }

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];

    self.isSearching = NO;
    [self.searchDataArray removeAllObjects];
    [self.searchTableView removeFromSuperview];
    [self.searchTableView reloadData];
    [self.tableView reloadData];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

#pragma mark - Data

- (NSArray *)_getInvitableUsers:(NSArray *)aAllUsers
{
    NSMutableArray *retNames = [[NSMutableArray alloc] init];
    [retNames addObjectsFromArray:aAllUsers];
    
    NSString *loginName = [[EMClient sharedClient].currentUsername lowercaseString];
    if ([retNames containsObject:loginName]) {
        [retNames removeObject:loginName];
    }
    
    for (NSString *name in self.excludeUsers) {
        if ([retNames containsObject:name]) {
            [retNames removeObject:name];
        }
    }
    
    return retNames;
}

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupMember...", nil)];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.gorcId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aError) {
            [weakSelf hideHud];
            [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
            
            [weakSelf showHint:[[NSString alloc] initWithFormat:NSLocalizedString(@"fetchGroupMemberFail", nil), aError.errorDescription]];
            return ;
        }
        
        weakSelf.cursor = aResult.cursor;
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
            
            EMError *error = nil;
            EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.gorcId error:&error];
            if (!error) {
                NSArray *owners = [weakSelf _getInvitableUsers:@[group.owner]];
                [weakSelf.dataArray addObjectsFromArray:owners];
                
                NSArray *admins = [weakSelf _getInvitableUsers:group.adminList];
                [weakSelf.dataArray addObjectsFromArray:admins];
            }
        }
        
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        
        NSArray *usernames = [weakSelf _getInvitableUsers:aResult.list];
        [weakSelf.dataArray addObjectsFromArray:usernames];
        [weakSelf.tableView reloadData];
        if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
    }];
}

- (void)_fetchChatroomMembersWithIsHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingChatroomMember...", nil)];
    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:self.gorcId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aError) {
            [weakSelf hideHud];
            [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
            
            [weakSelf showHint:[[NSString alloc] initWithFormat:NSLocalizedString(@"fetchChatroomMemberFail", nil), aError.errorDescription]];
            return ;
        }
        
        weakSelf.cursor = aResult.cursor;
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
            
            EMError *error = nil;
            EMChatroom *chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:weakSelf.gorcId error:&error];
            if (!error) {
                NSArray *owners = [weakSelf _getInvitableUsers:@[chatroom.owner]];
                [weakSelf.dataArray addObjectsFromArray:owners];
                
                NSArray *admins = [weakSelf _getInvitableUsers:chatroom.adminList];
                [weakSelf.dataArray addObjectsFromArray:admins];
            }
        }
        
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        
        NSArray *usernames = [weakSelf _getInvitableUsers:aResult.list];
        [weakSelf.dataArray addObjectsFromArray:usernames];
        [weakSelf.tableView reloadData];
        
        if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
            self.showRefreshFooter = NO;
        } else {
            self.showRefreshFooter = YES;
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    if (self.type == ConfInviteTypeUser) {
        NSArray *usernames = [self _getInvitableUsers:[[EMClient sharedClient].contactManager getContacts]];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:usernames];
        [self.tableView reloadData];
        
        [self tableViewDidFinishTriggerHeader:YES reload:NO];
    } else if (self.type == ConfInviteTypeGroup) {
        self.cursor = @"";
        [self _fetchGroupMembersWithIsHeader:YES];
    } else if (self.type == ConfInviteTypeChatroom) {
        self.cursor = @"";
        [self _fetchChatroomMembersWithIsHeader:YES];
    }
}

- (void)tableViewDidTriggerFooterRefresh
{
    if (self.type == ConfInviteTypeGroup) {
        [self _fetchGroupMembersWithIsHeader:NO];
    } else if (self.type == ConfInviteTypeChatroom) {
        [self _fetchChatroomMembersWithIsHeader:NO];
    } else {
        [self tableViewDidFinishTriggerHeader:NO reload:NO];
    }
}

#pragma mark - Action

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    if (self.isCreate) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    } else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)doneAction
{
//    __weak typeof(self) weakSelf = self;
//    [self dismissViewControllerAnimated:YES completion:^{
//        if (weakSelf.doneCompletion) {
//            weakSelf.doneCompletion(self.inviteUsers);
//        }
//    }];
//    return;
    
    if (self.isCreate) {
        BQ_WS
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.doneCompletion) {
                weakSelf.doneCompletion(self.inviteUsers);
            }
        }];
    } else {
        if (self.doneCompletion) {
            self.doneCompletion(self.inviteUsers);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)confirmButtonAction {
    
}


#pragma mark getter and setter
- (BQConfInviteSelectedUsersView *)confInviteSelectedUsersView {
    if (_confInviteSelectedUsersView == nil) {
        _confInviteSelectedUsersView = [[BQConfInviteSelectedUsersView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 70.0)];
    }
    return _confInviteSelectedUsersView;
}


- (UIView *)customNavBarView {
    if (_customNavBarView == nil) {
        _customNavBarView = [[UIView alloc] init];
        _customNavBarView.backgroundColor = UIColor.clearColor;
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.titleLabel.font = NFont(14.0);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithHexString:@"#B9B9B9"] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithHexString:@"#B9B9B9"] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_customNavBarView addSubview:self.titleLabel];
        [_customNavBarView addSubview:cancelButton];
        [_customNavBarView addSubview:self.confirmButton];
    
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_customNavBarView);
            make.centerX.equalTo(_customNavBarView);
            make.width.equalTo(@(100.0));
        }];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_customNavBarView).offset(16.0);
            make.centerY.equalTo(self.titleLabel);
            make.width.equalTo(@(60.0));
        }];

        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(_customNavBarView).offset(-16.0);
            make.size.equalTo(cancelButton);
        }];
    }
    return _customNavBarView;
}
- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
    }
    return _confirmButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _titleLabel;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.layer.cornerRadius = 32.0 * 0.5;

        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        searchField.backgroundColor = [UIColor colorWithHexString:@"#252525"];
        [searchField setTextColor:[UIColor colorWithHexString:@"#F5F5F5"]];
        searchField.tintColor = [UIColor colorWithHexString:@"#04D0A4"];
        searchField.layer.cornerRadius = 32.0 * 0.5;
        _searchBar.placeholder = @"搜索";
    }
    return _searchBar;
}

- (UITableView *)searchTableView {
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc] init];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.rowHeight = 64.0;
        _searchTableView.backgroundColor = ViewBgBlackColor;
    }
    return _searchTableView;
}

@end
