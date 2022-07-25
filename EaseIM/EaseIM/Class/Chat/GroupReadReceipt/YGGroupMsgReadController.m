//
//  YGGroupMsgReadController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/25.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupMsgReadController.h"
#import "BQAvatarTitleRoleCell.h"

@interface YGGroupMsgReadController ()<MISScrollPageControllerContentSubViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation YGGroupMsgReadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[BQAvatarTitleRoleCell class] forCellReuseIdentifier:NSStringFromClass([BQAvatarTitleRoleCell class])];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.dataArray = [@[[@(1) stringValue],[@(2) stringValue]] mutableCopy];

    [self.tableView reloadData];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BQAvatarTitleRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BQAvatarTitleRoleCell class])];
    
    id obj = self.dataArray[indexPath.row];
    [cell updateWithObj:obj isOwner:NO];
    
    return cell;
    
}


#pragma mark getter and setter
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
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
