//
//  BQAddGroupMemberViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQAddGroupMemberViewController.h"
#import "BQGroupSearchAddView.h"
#import "BQGroupSearchCell.h"


@interface BQAddGroupMemberViewController ()<UITableViewDelegate,UITableViewDataSource,BQGroupSearchAddViewDelegate>

@property (nonatomic, strong) BQGroupSearchAddView *groupSearchAddView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) UITableView *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *groupAddedArray;

@end

@implementation BQAddGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewBgBlackColor;
    self.title = @"选择用户";
    [self addPopBackLeftItemWithTarget:self action:@selector(backItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completionAction)];

    
    [self placeAndLayoutSubviews];
    
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)completionAction {
    if (self.searchResultArray.count > 0) {
        [self showHint:@"群主同意后，您邀请的成员将会自动加入本群聊"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)placeAndLayoutSubviews {
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.groupSearchAddView];
    [self.view addSubview:self.searchResultTableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(48.0));
    }];
    
    [self.groupSearchAddView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(0));
    }];
    
    
    [self.searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchAddView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}


- (void)dealloc
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark BQGroupSearchAddViewDelegate
- (void)heightForGroupSearchAddView:(CGFloat)height {
    [self.groupSearchAddView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    if (!self.isSearching) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.isSearching = YES;
    }
}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isSearching = NO;
    
    [self.searchResultArray removeAllObjects];
    [_searchResultTableView reloadData];
    [_searchResultTableView removeFromSuperview];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString {
    [self.searchResultArray removeAllObjects];
    [self.searchResultArray addObject:aString];
    [self.searchResultTableView reloadData];
}


#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [_searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}



- (void)keyBoardWillHide:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [_searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BQGroupSearchCell *groupSearchCell = [tableView dequeueReusableCellWithIdentifier:[BQGroupSearchCell reuseIdentifier]];
    
    id obj = self.searchResultArray[indexPath.row];
    [groupSearchCell updateWithObj:obj];
    
    BQ_WS
    groupSearchCell.customerBlock = ^(NSString * _Nonnull userId) {
        [weakSelf updateUIWithAddUserId:userId isServicer:NO];
    };
    
    groupSearchCell.servicerBlock = ^(NSString * _Nonnull userId) {
        [weakSelf updateUIWithAddUserId:userId isServicer:YES];
    };
    return groupSearchCell;
}
 
- (void)updateUIWithAddUserId:(NSString *)userId
                   isServicer:(BOOL)isServicer {
    
    if (![self.groupAddedArray containsObject:userId]) {
        [self.groupAddedArray addObject:userId];
    }
    
    [self.groupSearchAddView updateUIWithMemberArray:self.groupAddedArray];
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];
    hView.backgroundColor = [UIColor colorWithHexString:@"#171717"];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = NFont(14.0);
    titleLabel.textColor = [UIColor colorWithHexString:@"#7E7E7E"];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.text = @"搜索结果";
    
    [hView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(hView).insets(UIEdgeInsetsMake(0, 16.0, 0, 0));
    }];
    
    return hView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}


#pragma mark getter and setter
- (BQGroupSearchAddView *)groupSearchAddView {
    if (_groupSearchAddView == nil) {
        _groupSearchAddView = [[BQGroupSearchAddView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _groupSearchAddView.delegate = self;
        
        BQ_WS
        _groupSearchAddView.deleteMemberBlock = ^(NSString * _Nonnull userId) {
            [weakSelf.groupAddedArray removeObject:userId];
        };
    }
    return _groupSearchAddView;
}


- (UITableView *)searchResultTableView {
    if (_searchResultTableView == nil) {
        _searchResultTableView = [[UITableView alloc] init];
        _searchResultTableView.tableFooterView = [[UIView alloc] init];
        _searchResultTableView.delegate = self;
        _searchResultTableView.dataSource = self;
        
        [_searchResultTableView registerClass:[BQGroupSearchCell class] forCellReuseIdentifier:NSStringFromClass([BQGroupSearchCell class])];
        
        _searchResultTableView.backgroundColor = ViewBgBlackColor;
    }
    return _searchResultTableView;
}



- (NSMutableArray *)searchResultArray {
    if (_searchResultArray == nil) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}


- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (NSMutableArray *)groupAddedArray {
    if (_groupAddedArray == nil) {
        _groupAddedArray = [[NSMutableArray alloc] init];
    }
    return _groupAddedArray;
}

@end
