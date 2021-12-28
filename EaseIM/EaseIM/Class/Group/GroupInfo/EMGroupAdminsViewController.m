//
//  EMGroupAdminsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupAdminsViewController.h"
#import "EMAvatarNameCell+UserInfo.h"
#import "EMPersonalDataViewController.h"
#import "UserInfoStore.h"
#import "EMAccountViewController.h"

@interface EMGroupAdminsViewController ()

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSMutableArray *mutesList;
@property (nonatomic) BOOL isUpdated;

@end

@implementation EMGroupAdminsViewController

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
    // Do any additional setup after loading the view.
    self.isUpdated = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    [self _setupSubviews];
    [self _fetchGroupAdminsWithIsShowHUD:YES];
    self.mutesList = [[NSMutableArray alloc]init];
    [self _fetchGroupMutes:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = NSLocalizedString(@"groupAdmin", nil);
    self.showRefreshHeader = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EMAvatarNameCell"];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    [cell refreshUserInfo:[self.dataArray objectAtIndex:indexPath.row]];
    cell.indexPath = indexPath;
    if (indexPath.row == 0)
        cell.detailTextLabel.text = NSLocalizedString(@"groupOwner", nil);
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self personalData:[self.dataArray objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == 0)
        return NO;
    return self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"remove", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _deleteAdmin:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"bringtobl", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _blockAdmin:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"mute", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _muteAdmin:userName];
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    UITableViewRowAction *adminAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"downRight", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _adminToMember:userName];
    }];
    adminAction.backgroundColor = [UIColor blackColor];
    
    return @[deleteAction, blackAction, muteAction, adminAction];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    NSMutableArray *swipeActions = [[NSMutableArray alloc] init];
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:NSLocalizedString(@"remove", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _deleteAdmin:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UIContextualAction *blackAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:NSLocalizedString(@"bringtobl", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _blockAdmin:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UIContextualAction *muteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:[weakself.mutesList containsObject:userName] ? NSLocalizedString(@"unmute", nil) : NSLocalizedString(@"mute", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        if ([weakself.mutesList containsObject:userName]) {
            [weakself _unMuteAdmin:userName];
        } else {
            [weakself _muteAdmin:userName];
        }
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    [swipeActions addObject:deleteAction];
    [swipeActions addObject:blackAction];
    [swipeActions addObject:muteAction];
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        UIContextualAction *adminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                   title:NSLocalizedString(@"downRight", nil)
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                            {
            [weakself _adminToMember:userName];
        }];
        adminAction.backgroundColor = [UIColor blackColor];
        [swipeActions addObject:adminAction];
    }
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - Data

- (void)_fetchGroupAdminsWithIsShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupAdmins...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            weakself.group = aGroup;
            
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObject:aGroup.owner];
            [weakself.dataArray addObjectsFromArray:aGroup.adminList];
            [weakself.tableView reloadData];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)_fetchGroupMutes:(int)aPage
{
    if (self.group.permissionType == EMGroupPermissionTypeMember || self.group.permissionType == EMGroupPermissionTypeNone) {
        return;
    }
    if (aPage == 1) {
        [self.mutesList removeAllObjects];
    }
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMuteListFromServerWithId:self.group.groupId pageNumber:aPage pageSize:200 completion:^(NSArray *aList, EMError *aError) {
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            [weakself.mutesList addObjectsFromArray:aList];
        }
        if ([aList count] == 200) {
            [weakself _fetchGroupMutes:(aPage + 1)];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self _fetchGroupAdminsWithIsShowHUD:NO];
}

#pragma mark - Action

- (void)_deleteAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"removeGroupAdmins", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager removeMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"removeAdminFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"removeAdminSuccess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_blockAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"moveToBL", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager blockMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"moveToBLFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"moveToBLSuccess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_muteAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"muteGroupAdmins", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager muteMembers:@[aUsername] muteMilliseconds:-1 fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"muteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"muteSuccess", nil)];
            [weakself _fetchGroupMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_unMuteAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"unmuteGroupMember", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager unmuteMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"unmuteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"unmuteSuccess", nil)];
            [weakself _fetchGroupMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_adminToMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"beMember", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager removeAdmin:aUsername fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"beMemberFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"beMemberSuccess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_UPDATED object:self.group];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//个人资料卡
- (void)personalData:(NSString *)nickName
{
    UIViewController* controller = nil;
    if([[EMClient sharedClient].currentUsername isEqualToString:nickName]) {
        controller = [[EMAccountViewController alloc] init];
    }else{
        controller = [[EMPersonalDataViewController alloc]initWithNickName:nickName];
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        [nav pushViewController:controller animated:YES];
    }
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

@end
