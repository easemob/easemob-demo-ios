//
//  YGGroupApplyController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupApplyApprovalController.h"
#import "YGGroupApplyApprovalCell.h"

@interface YGGroupApplyApprovalController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;


@end

@implementation YGGroupApplyApprovalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addPopBackLeftItem];
    self.title = @"群组申请";
    self.view.backgroundColor = ViewBgWhiteColor;
    
    [self.tableView registerClass:[YGGroupApplyApprovalCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupApplyApprovalCell class])];

    [self placeAndLayoutSubviews];
    
    self.dataArray = [@[@(1),@(2)] mutableCopy];
    [self.tableView reloadData];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGGroupApplyApprovalCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YGGroupApplyApprovalCell class]) forIndexPath:indexPath];
    id obj = self.dataArray[indexPath.row];
    [cell updateWithObj:obj];
    cell.approvalBlock = ^(BOOL agree) {
        
    };
    
    return cell;
}


#pragma mark getter and setter
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;        
        _tableView.backgroundColor = ViewBgWhiteColor;
    }

    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
}

@end
