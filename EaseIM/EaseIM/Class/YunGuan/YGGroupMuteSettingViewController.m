//
//  YGGroupBanSettingViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupMuteSettingViewController.h"
#import "YGGroupMuteMemberCell.h"
#import "YGGroupAddMuteCell.h"
#import "YGGroupAddMuteViewController.h"


@interface YGGroupMuteSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSMutableArray *unMuteArray;

@end

@implementation YGGroupMuteSettingViewController

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
if ([EMDemoOptions sharedOptions].isJiHuApp) {
    self.view.backgroundColor = ViewBgBlackColor;
}else {
    self.view.backgroundColor = ViewBgWhiteColor;
}
    self.title = @"群禁言设置";
    [self addPopBackLeftItemWithTarget:self action:@selector(backItemAction)];
    
    [self placeAndLayoutSubviews];
    
    [self updateUI];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (void)goAddMutePage {
    YGGroupAddMuteViewController *vc = [[YGGroupAddMuteViewController alloc] init];
    vc.dataArray = self.unMuteArray;
    BQ_WS
    vc.doneCompletion = ^(NSArray * _Nonnull selectedArray) {
        [weakSelf updateUIWithAddMutes:selectedArray];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateUIWithAddMutes:(NSArray *)mutes {
    [[EMClient sharedClient].groupManager muteMembers:mutes muteMilliseconds:0 fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            [self.dataArray addObjectsFromArray:mutes];
            [self.unMuteArray removeObjectsInArray:mutes];
            [self.tableView reloadData];
        }else {
            [EMAlertController showErrorAlert:aError.debugDescription];
        }
    }];
}

- (void)updateUI {
    NSMutableArray *memberArray = [NSMutableArray array];
    if (self.group.adminList.count > 0) {
        [memberArray addObjectsFromArray:self.group.adminList];
    }
    if (self.group.memberList.count > 0) {
        [memberArray addObjectsFromArray:self.group.memberList];
    }

    NSMutableSet *memberSet = [NSMutableSet setWithArray:memberArray];
    
    NSMutableSet *muteSet = [NSMutableSet setWithArray:self.group.muteList];
    
    [memberSet minusSet:muteSet];
    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [memberSet sortedArrayUsingDescriptors:sortDesc];

    self.unMuteArray = [sortSetArray mutableCopy];
    self.dataArray = [self.group.muteList mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YGGroupMuteMemberCell height];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGGroupAddMuteCell *addBanCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupAddMuteCell reuseIdentifier]];
    
    YGGroupMuteMemberCell *banMemberCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupMuteMemberCell reuseIdentifier]];
    
    BQ_WS
    if (indexPath.row == 0) {
        addBanCell.tapCellBlock = ^{
            [weakSelf goAddMutePage];
        };
        
        return addBanCell;
    }
   
    id obj = self.dataArray[indexPath.row - 1];
    [banMemberCell updateWithObj:obj];
    banMemberCell.unBanBlock = ^(NSString * _Nonnull userId) {
        [weakSelf updateUIWithUnBanUserId:userId];
    };
    return banMemberCell;
}
 
- (void)updateUIWithUnBanUserId:(NSString *)userId {
    if (userId == nil) {
        return;
    }
    
    [[EMClient sharedClient].groupManager unmuteMembers:@[userId] fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {

        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.dataArray containsObject:userId]) {
                    [self.dataArray removeObject:userId];
                }

                [self.tableView reloadData];
            });
        }else {
            [EMAlertController showErrorAlert:aError.debugDescription];
        }
        
    }];
}

#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[YGGroupAddMuteCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupAddMuteCell class])];
        
        [_tableView registerClass:[YGGroupMuteMemberCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupMuteMemberCell class])];

        if ([EMDemoOptions sharedOptions].isJiHuApp) {
              _tableView.backgroundColor = ViewBgBlackColor;

        }else {
                _tableView.backgroundColor = ViewBgWhiteColor;
        }

    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)unMuteArray {
    if (_unMuteArray == nil) {
        _unMuteArray = [[NSMutableArray alloc] init];
    }
    return _unMuteArray;
}

@end
