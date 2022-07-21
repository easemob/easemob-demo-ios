//
//  YGGroupSearchViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/18.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupSearchViewController.h"
#import "YGGroupSearchView.h"

#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"
#import "YGAvatarTitleAccessCell.h"
#import "BQNoDataPlaceHolderView.h"
#import "YGGroupSearchTypeTableView.h"
#import "YGSearchGroup.h"
#import "EMChatViewController.h"


@interface YGGroupSearchViewController ()<UITableViewDelegate,UITableViewDataSource,YGGroupSearchViewDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) YGGroupSearchView *groupSearchView;
@property (nonatomic, strong) BQNoDataPlaceHolderView *noDataPromptView;
@property (nonatomic, strong) YGGroupSearchTypeTableView *searchTypeTableView;
@property (nonatomic, assign) YGSearchGroupType searchGroupType;

@end

@implementation YGGroupSearchViewController

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
    
    self.view.backgroundColor = ViewBgWhiteColor;

    [self placeAndLayoutSubviews];
    
    [self.tableView reloadData];
}

- (void)tapAction {
    self.searchTypeTableView.hidden = YES;
    
}

#pragma mark - Subviews

- (void)placeAndLayoutSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
        
    [self.view addSubview:self.groupSearchView];
    [self.view addSubview:self.tableView];

    [self.groupSearchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(52.0));
    }];

    [self.view addSubview:self.searchTypeTableView];
    [self.searchTypeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom).offset(-10.0);
        make.left.equalTo(self.groupSearchView.leftBackButton.mas_right);
        make.right.equalTo(self.groupSearchView.vLineImageView.mas_right);
//        make.width.equalTo(@(110.0));
        make.height.equalTo(@(144.0));
    }];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom).offset(60.0);
        make.centerX.left.right.equalTo(self.view);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"YGAvatarTitleAccessCell";
    YGAvatarTitleAccessCell *cell = (YGAvatarTitleAccessCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
   
    [cell updateWithObj:obj];
    BQ_WS
    cell.accessBlock = ^(NSString * _Nonnull groupId) {
        [weakSelf goGroupChatPageWithGroupId:groupId];
    };
    
    return cell;
}

- (void)goGroupChatPageWithGroupId:(NSString *)groupId {
    EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:groupId conversationType:EMConversationTypeGroupChat];
    
    [self.navigationController pushViewController:controller animated:YES];
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}


#pragma mark - YGGroupSearchViewDelegate
- (void)showSearchGroupTypeTable {
    self.searchTypeTableView.hidden = NO;
}

- (void)searchButtonClickedWithKeyword:(NSString *)keyword {
    [self searchGroupWithKeyword:keyword];
}

- (void)searchViewShouldBeginEditing:(YGGroupSearchView *)searchView{
    
}

#pragma mark private method
- (void)searchGroupWithKeyword:(NSString *)keyword {
    if (keyword.length == 0) {
        [self.dataArray removeAllObjects];
    }
    [self buildTempData];
    self.noDataPromptView.hidden = self.dataArray.count > 0 ? YES:NO;
    [self.tableView reloadData];
}

- (void)buildTempData {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < 3; ++i) {
        YGSearchGroup *group = YGSearchGroup.new;
        group.groupId = [NSString stringWithFormat:@"%@",@(i)];
        group.groupName = [NSString stringWithFormat:@"group_%@",@(i)];
        
        if (i/2 == 0) {
            group.isGroupMember = YES;
        }
        [tempArray addObject:group];
    }
    
    self.dataArray = tempArray;
}


#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0;
    
        [_tableView registerClass:[YGAvatarTitleAccessCell class] forCellReuseIdentifier:NSStringFromClass([YGAvatarTitleAccessCell class])];
                
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tap.numberOfTapsRequired = 1;
        [_tableView addGestureRecognizer:tap];

    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (YGGroupSearchView *)groupSearchView {
    if (_groupSearchView == nil) {
        _groupSearchView = [[YGGroupSearchView alloc] init];
        _groupSearchView.delegate = self;
        
        BQ_WS
        _groupSearchView.backActionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _groupSearchView;
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

- (YGGroupSearchTypeTableView *)searchTypeTableView {
    if (_searchTypeTableView == nil) {
        _searchTypeTableView = [[YGGroupSearchTypeTableView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _searchTypeTableView.hidden = YES;

        BQ_WS
        _searchTypeTableView.selectedBlock = ^(NSString * _Nonnull selectedName, NSInteger selectedType) {
            weakSelf.groupSearchView.searchTypeLabel.text = selectedName;
            weakSelf.searchGroupType = selectedType;
            weakSelf.searchTypeTableView.hidden = YES;
        };
        _searchTypeTableView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        _searchTypeTableView.layer.shadowColor = UIColor.grayColor.CGColor;
    }
    return _searchTypeTableView;
}


@end


