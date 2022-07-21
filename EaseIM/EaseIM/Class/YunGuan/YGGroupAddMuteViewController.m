//
//  YGGroupAddBanViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupAddMuteViewController.h"
#import "EMSearchBar.h"
#import "ConfInviteUserCell.h"
#import "EMRealtimeSearch.h"

@interface YGGroupAddMuteViewController ()<UITableViewDelegate,UITableViewDataSource,EMSearchBarDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMSearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation YGGroupAddMuteViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addPopBackLeftItem];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    
    self.view.backgroundColor = ViewBgWhiteColor;

    [self _setupSubviews];
    
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
        
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8.0);
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

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConfInviteUserCell";
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *username = self.isSearching ? [self.searchArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    
    [cell updateWithObj:username];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *username = self.isSearching ? [self.searchArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.selectedArray containsObject:username];
    if (isChecked) {
        [self.selectedArray removeObject:username];
    } else {
        [self.selectedArray addObject:username];
    }
    cell.isChecked = !isChecked;
    
}

#pragma mark - EMSearchBarDelegate
- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    if (!self.isSearching) {
        self.isSearching = YES;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    self.isSearching = NO;
    [self.searchArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    if (!self.isSearching) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchArray removeAllObjects];
            [weakself.searchArray addObjectsFromArray:results];
            [weakself.tableView reloadData];
        });
    }];
}

#pragma mark - Action

- (void)doneAction
{
    if (_doneCompletion) {
        _doneCompletion(self.selectedArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark getter and setter
- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0;
        
        UINib *nib = [UINib nibWithNibName:@"ConfInviteUserCell" bundle:nil];
        [_tableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
        
        _tableView.backgroundColor = ViewBgWhiteColor;
    }
    return _tableView;
}



- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)searchArray {
    if (_searchArray == nil) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

- (NSMutableArray *)selectedArray {
    if (_selectedArray == nil) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

@end

