//
//  EMChatroomAdminsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomAdminsViewController.h"
#import "EMPersonalDataViewController.h"
#import "EMAvatarNameCell+UserInfo.h"
#import "EMAccountViewController.h"

@interface EMChatroomAdminsViewController ()

@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic, strong) NSMutableArray *mutesList;
@property (nonatomic) BOOL isUpdated;

@end

@implementation EMChatroomAdminsViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isUpdated = NO;
    
    [self _setupSubviews];
    [self _fetchChatroomAdminsWithIsShowHUD:YES];
    self.mutesList = [[NSMutableArray alloc]init];
    [self _fetchChatRoomMutes:1];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = NSLocalizedString(@"chatroomAdmins", nil);
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
    cell.indexPath = indexPath;
    [cell refreshUserInfo:[self.dataArray objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = NSLocalizedString(@"Admins", nil);
    if (indexPath.row == 0)
        cell.detailTextLabel.text = NSLocalizedString(@"owner", nil);
    
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner) {
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
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    return (self.chatroom.permissionType == EMChatroomPermissionTypeOwner && ![userName isEqualToString:EMClient.sharedClient.currentUsername]) ? YES : NO;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    __weak typeof(self) weakself = self;
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
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
    
    UIContextualAction *adminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                            title:NSLocalizedString(@"downRight", nil)
                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        [weakself _adminToMember:userName];
    }];
    adminAction.backgroundColor = [UIColor blackColor];
    
    UIContextualAction *transferAdminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                            title:NSLocalizedString(@"transfer", nil)
                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        __weak typeof(self) weakself = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"changeChatroomOwnerPrompt", nil),userName] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"transfer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself _transferChatroom:userName];
        }];
        [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        [alertController addAction:clearAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [alertController addAction:cancelAction];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    transferAdminAction.backgroundColor = [UIColor systemGrayColor];

    NSMutableArray *swipeActions = [[NSMutableArray alloc]init];
    [swipeActions addObject:deleteAction];
    [swipeActions addObject:blackAction];
    [swipeActions addObject:muteAction];
    [swipeActions addObject:adminAction];
    if ([self.chatroom.owner isEqualToString:EMClient.sharedClient.currentUsername]) {
        [swipeActions addObject:transferAdminAction];
    }
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - Data

- (void)_fetchChatroomAdminsWithIsShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchAdmins...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            weakself.chatroom = aChatroom;
            
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObject:aChatroom.owner];
            [weakself.dataArray addObjectsFromArray:aChatroom.adminList];
            [weakself.tableView reloadData];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)_fetchChatRoomMutes:(int)aPage
{
    if (self.chatroom.permissionType == EMChatroomPermissionTypeMember || self.chatroom.permissionType == EMChatroomPermissionTypeNone) {
        return;
    }
    if (aPage == 1) {
        [self.mutesList removeAllObjects];
    }
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomMuteListFromServerWithId:self.chatroom.chatroomId pageNumber:aPage pageSize:200 completion:^(NSArray *aList, EMError *aError) {
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            [weakself.mutesList addObjectsFromArray:aList];
        }
        if ([aList count] == 200) {
            [weakself _fetchChatRoomMutes:(aPage + 1)];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self _fetchChatroomAdminsWithIsShowHUD:NO];
}

#pragma mark - Action

- (void)_deleteAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:NSLocalizedString(@"removeAdmin...", nil)];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager removeMembers:@[aUsername] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
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
    [self showHudInView:self.view hint:NSLocalizedString(@"removeToBL...", nil)];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager blockMembers:@[aUsername] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
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
    [self showHudInView:self.view hint:NSLocalizedString(@"muteAdmins...", nil)];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager muteMembers:@[aUsername] muteMilliseconds:-1 fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"muteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"muteSuccess", nil)];
            [weakself _fetchChatRoomMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_unMuteAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:NSLocalizedString(@"unmuteMember...", nil)];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager unmuteMembers:@[aUsername] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"muteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"muteSuccess", nil)];
            [weakself _fetchChatRoomMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_adminToMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:NSLocalizedString(@"downRoleAdmin...", nil)];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager removeAdmin:aUsername fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
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

- (void)_transferChatroom:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"changeChatroomTo...", nil),aUsername]];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager updateChatroomOwner:self.chatroom.chatroomId newOwner:aUsername completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"transferChatroomFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:NSLocalizedString(@"transferChatroomSuccess", nil)];
            [weakself _fetchChatroomAdminsWithIsShowHUD:NO];
        }
    }];
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

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATROOM_INFO_UPDATED object:self.chatroom];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
