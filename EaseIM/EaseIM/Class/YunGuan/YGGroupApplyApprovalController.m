//
//  YGGroupApplyController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupApplyApprovalController.h"
#import "YGGroupApplyApprovalCell.h"

@interface YGGroupApplyApprovalController ()
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation YGGroupApplyApprovalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addPopBackLeftItem];
    self.title = @"群组申请";
    
    self.dataArray = [@[@(1),@(2)] mutableCopy];
    
    [self.tableView registerClass:[YGGroupApplyApprovalCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupApplyApprovalCell class])];

    [self.tableView reloadData];
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
//- (UITableView *)tableView
//{
//    if (_tableView == nil) {
//        _tableView = [[UITableView alloc] init];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        _tableView.tableFooterView = self.defaultFooterView;
//        _tableView.estimatedSectionHeaderHeight = 0;
//        _tableView.estimatedSectionFooterHeight = 0;
//    }
//
//    return _tableView;
//}

@end
