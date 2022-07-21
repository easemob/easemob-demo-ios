//
//  EMGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupInfoViewController.h"

#import "EMAvatarNameCell.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"
#import "EMGroupOwnerViewController.h"
#import "EMGroupMembersViewController.h"
#import "EMGroupAdminsViewController.h"
#import "EMGroupMutesViewController.h"
#import "EMGroupBlacklistViewController.h"
#import "EMGroupSharedFilesViewController.h"
#import "EMGroupSettingsViewController.h"
#import "EMInviteGroupMemberViewController.h"
#import "EMGroupManageViewController.h"
#import "EMGroupAllMembersViewController.h"
#import "EMChatRecordViewController.h"
#import <EaseIMKit/EaseIMKit.h>

@interface EMGroupInfoViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) EMAvatarNameCell *addMemberCell;
@property (nonatomic, strong) UITableViewCell *leaveCell;
@property (nonatomic, strong) UILabel *leaveCellContentLabel;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;

@end

@implementation EMGroupInfoViewController

- (instancetype)initWithConversation:(EMConversation *)aConversation
{
    self = [super init];
    if (self) {
        _groupId = aConversation.conversationId;
        _conversation = aConversation;
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:aConversation];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
//    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    self.showRefreshHeader = NO;
    [self _fetchGroupWithId:self.groupId isShowHUD:YES];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInfo) name:GROUP_INFO_REFRESH object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak typeof(self) weakself = self;
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            weakself.group = aGroup;
            [weakself _resetGroup:aGroup];
        } else {
            [EMAlertController showErrorAlert:[NSString stringWithFormat:NSLocalizedString(@"fetchGroupSubjectFail", nil),aError.description]];
        }
    }];
}

- (void)reloadInfo
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = NSLocalizedString(@"groupInfo", nil);

    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.addMemberCell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    self.addMemberCell.avatarView.image = [UIImage imageNamed:@"group_join"];
    self.addMemberCell.nameLabel.textColor = kColor_Blue;
    self.addMemberCell.nameLabel.text = NSLocalizedString(@"inviteMembers", nil);
    self.addMemberCell.separatorInset = UIEdgeInsetsMake(0, [UIScreen mainScreen].bounds.size.width, 0, 0);
    
    self.leaveCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefaultRedFont"];
    self.leaveCellContentLabel = [[UILabel alloc]init];
    self.leaveCellContentLabel.text = NSLocalizedString(@"remove&exit", nil);
    self.leaveCellContentLabel.textColor = [UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0];
    self.leaveCellContentLabel.font = [UIFont systemFontOfSize:18.0];
    [self.leaveCell.contentView addSubview:self.leaveCellContentLabel];
    [self.leaveCellContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.leaveCell.contentView);
    }];
    self.leaveCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, [UIScreen mainScreen].bounds.size.width);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (((self.group.setting.style == EMGroupStylePrivateOnlyOwnerInvite || self.group.setting.style == EMGroupStylePublicJoinNeedApproval) && (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin)) || self.group.setting.style == EMGroupStylePrivateMemberCanInvite || self.group.setting.style == EMGroupStylePublicOpenJoin) {
            return 3;
        }
        return 2;
    }
    if (section == 1) {
        if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin)
            return 5;
        return 4;
    }
    if (section == 2)
        return 1;
    if (section == 3)
        return 2;
    if (section == 4)
        return 1;
    if (section == 5)
        return 1;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section == 0 && row == 0) {
        cellIdentifier = @"UITableViewCellStyleSubtitle";
    }
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 3) {
        isSwitchCell = YES;
        cellIdentifier = @"UITableViewCellSwitch";
    }

    UITableViewCell *cell = nil;
    if (!isSwitchCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    // Configure the cell...
    if (cell == nil) {
        if (section == 0 && row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (isSwitchCell) {
        switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
        switchControl.tag = [self _tagWithIndexPath:indexPath];
        [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchControl];
    }
        //switchControl = [cell.contentView viewWithTag:[self _tagWithIndexPath:indexPath]];
    
    if (section == 5 && row == 0)
        return self.leaveCell;
    if (section == 0 && row == 2)
        return self.addMemberCell;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == 0) {
        if (row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"groupChat"];
            cell.textLabel.font = [UIFont systemFontOfSize:18.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.textLabel.text = self.group.groupName;
            if (self.group.description && ![self.group.description isEqualToString:@""]) {
                cell.detailTextLabel.text = self.group.description;
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"noGroupDescription", nil);
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"groupMembers", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"groupCount", nil),(long)self.group.occupantsCount];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, [UIScreen mainScreen].bounds.size.width);
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"groupSubject", nil);
            cell.detailTextLabel.text = self.group.groupName;
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"sharedFile", nil);
            cell.detailTextLabel.text = @"";
        } else if (row == 2) {
            cell.textLabel.text = NSLocalizedString(@"groupAnn", nil);
            cell.detailTextLabel.text = self.group.announcement;
        } else if (row == 3) {
            cell.textLabel.text = NSLocalizedString(@"groupDescription", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.group.description];
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 4) {
            cell.textLabel.text = NSLocalizedString(@"groupAdmin", nil);
            cell.detailTextLabel.text = @"";
        }
    }  else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"searchMsgList", nil);
            cell.detailTextLabel.text = @"";
        }
    } else if (section == 3) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"noNotice", nil);
            [switchControl setOn:!self.group.isPushNotificationEnabled animated:YES];
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"conversationTop", nil);
            [switchControl setOn:[self.conversationModel isTop] animated:YES];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (section == 4) {
        cell.textLabel.text = NSLocalizedString(@"clearConversation", nil);
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
        return 50;
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.001;
    
    return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            //群成员
            EMGroupAllMembersViewController *controller = [[EMGroupAllMembersViewController alloc]initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            //邀请成员
            [self addMemberAction];
        }
    } else if (section == 1) {
        if (row == 0) {
             //修改群名称
            [self _updateGroupNameAction];
        } else if (row == 1) {
            //群共享文件
            EMGroupSharedFilesViewController *controller = [[EMGroupSharedFilesViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            [self groupAnnouncementAction];
        } else if (row == 3) {
            //群介绍
            [self _updateGroupDetailAction];
        } else if (row == 4) {
            //群管理
            EMGroupManageViewController *controller = [[EMGroupManageViewController alloc]initWithGroup:self.groupId];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            //查找聊天记录
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
            EMChatRecordViewController *chatRrcordController = [[EMChatRecordViewController alloc]initWithCoversationModel:conversation];
            //EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:self.conversationModel.emModel.conversationId type:EMConversationTypeChat createIfNotExist:NO isChatRecord:YES];
            [self.navigationController pushViewController:chatRrcordController animated:YES];
        }
    } else if (section == 4) {
        //删除聊天记录
        [self deleteGroupRecord];
    } else if (section == 5) {
        if (row == 0) {
            [self _leaveOrDestroyGroupAction];
        }
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    switch (aEvent) {
        case EMMultiDevicesEventGroupKick:
        case EMMultiDevicesEventGroupBan:
        case EMMultiDevicesEventGroupAllow:
        case EMMultiDevicesEventGroupAssignOwner:
        case EMMultiDevicesEventGroupAddAdmin:
        case EMMultiDevicesEventGroupRemoveAdmin:
        case EMMultiDevicesEventGroupAddMute:
        case EMMultiDevicesEventGroupRemoveMute:
        {
            if ([aGroupId isEqualToString:self.group.groupId]) {
                [self.tableView reloadData];
            }
        }
            
        default:
            break;
    }
}

#pragma mark - Data

- (void)_resetGroup:(EMGroup *)aGroup
{
    if (![self.group.groupName isEqualToString:aGroup.groupName]) {
        if (_conversation) {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:_conversation.ext];
            [ext setObject:aGroup.groupName forKey:@"subject"];
            [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
            _conversation.ext = ext;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_SUBJECT_UPDATED object:aGroup];
        }
    }
    
    self.group = aGroup;
    if (aGroup.permissionType == EMGroupPermissionTypeOwner) {
        self.leaveCellContentLabel.text = NSLocalizedString(@"destoryGroup", nil);
    } else {
        self.leaveCellContentLabel.text = NSLocalizedString(@"exitGroup", nil);
    }
    [self.tableView reloadData];
}

- (void)_fetchGroupWithId:(NSString *)aGroupId
                isShowHUD:(BOOL)aIsShowHUD
{
    __weak typeof(self) weakself = self;
    
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchGroupSubject...", nil)];
    }
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:aGroupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself _resetGroup:aGroup];
        } else {
            [EMAlertController showErrorAlert:NSLocalizedString(@"fetchGroupSubjectFail", nil)];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.leaveOrDestroyCompletion) {
        self.leaveOrDestroyCompletion();
    }
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    if ([aAdmin isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}
- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    if ([aAdmin isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}
- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    if ([aOldOwner isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

#pragma mark - NSNotification

- (void)handleGroupInfoUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group || ![group.groupId isEqualToString:self.groupId]) {
        return;
    }
    
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - Action
//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 3) {
        if (row == 0) {
            //免打扰
            __weak typeof(self) weakself = self;
            
            [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
            [EMClient.sharedClient.groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:!aSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
                if (!aError) {
                    weakself.group = aGroup;
                } else {
                    if (aError) {
                        [weakself showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
                        [aSwitch setOn:NO];
                    }
                }
            }];
        } else if (row == 1) {
            //置顶
            if (aSwitch.isOn) {
                [self.conversationModel setIsTop:YES];
            } else {
                [self.conversationModel setIsTop:NO];
            }
        }
    }
}

//清空聊天记录
- (void)deleteGroupRecord
{
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"removeGroupMsgs", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"clear", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        if (weakself.clearRecordCompletion) {
            if (!error) {
                [EMAlertController showSuccessAlert:NSLocalizedString(@"cleared", nil)];
                weakself.clearRecordCompletion(YES);
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"clearFail", nil)];
                weakself.clearRecordCompletion(NO);
            }
        }
    }];
    [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    [alertController addAction:clearAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)groupAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupAnn...", nil)];
    [[EMClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            BOOL isEditable = NO;
            if (weakself.group.permissionType == EMGroupPermissionTypeOwner || weakself.group.permissionType == EMGroupPermissionTypeAdmin) {
                isEditable = YES;
            }
            NSString *hint;
            if (isEditable) {
                hint = NSLocalizedString(@"inputGroupAnn", nil);
            } else {
                hint = NSLocalizedString(@"noGroupAnn", nil);
            }
            EMTextViewController *controller = [[EMTextViewController alloc] initWithString:aAnnouncement placeholder:hint isEditable:isEditable];
            controller.title = NSLocalizedString(@"groupAnn", nil);
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupAnn...", nil)];
                [[EMClient sharedClient].groupManager updateGroupAnnouncementWithId:weakself.groupId announcement:aString completion:^(EMGroup *aGroup, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
                        weakself.group = aGroup;
                        [EMAlertController showErrorAlert:NSLocalizedString(@"updateGroupAnnFail", nil)];
                    } else {
                        [weakController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
                return NO;
            }];
            
            [weakself.navigationController pushViewController:controller animated:YES];
        } else {
            [EMAlertController showErrorAlert:NSLocalizedString(@"fetchGroupAnnFail", nil)];
        }
    }];
}
/*
//获取我的群昵称
- (NSString *)acquireGroupNickNamkeOfMine
{
    NSMutableDictionary *nickNameDict = [self changeStringToDictionary:self.group.setting.ext];
    if (nickNameDict) {
        return [nickNameDict objectForKey:EMClient.sharedClient.currentUsername];
    }
    return EMClient.sharedClient.currentUsername;
}

//修改我的群昵称
- (void)_updateGroupNickNameOfMine
{
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:[self acquireGroupNickNamkeOfMine] placeholder:NSLocalizedString(@"inputGroupNickname", nil) isEditable:YES];
    controller.title = NSLocalizedString(@"editGroupSubject", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        NSMutableDictionary *nickNameDic = [weakself changeStringToDictionary:weakself.group.setting.ext];
        if (!nickNameDic) {
            nickNameDic = [[NSMutableDictionary alloc]init];
        }
        if ([aString length] == 0) {
            [nickNameDic setObject:EMClient.sharedClient.currentUsername forKey:EMClient.sharedClient.currentUsername];
        } else {
            [nickNameDic setObject:aString forKey:EMClient.sharedClient.currentUsername];
        }
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateNickname...", nil)];
        [weakController hideHud];
        //修改我的群昵称
        NSData *data=[NSJSONSerialization dataWithJSONObject:nickNameDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //[weakself.group.setting setExt:str];
        [EMClient.sharedClient.groupManager updateGroupExtWithId:weakself.group.groupId ext:str completion:^(EMGroup *aGroup, EMError *aError) {
            NSLog(@"%@", [NSString stringWithFormat:@"ext :    %@",weakself.group.setting.ext]);
            [weakself.tableView reloadData];
            [weakController.navigationController popViewControllerAnimated:YES];

        }];
        return NO;
    }];
}
*/
- (void)_updateGroupNameAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    if (!isEditable) {
        return;
    }
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.group.groupName placeholder:NSLocalizedString(@"inputGroupSubject", nil) isEditable:isEditable];
    controller.title = NSLocalizedString(@"editGroupSubject", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"emtpyGroupSubject", nil)];
            return NO;
        }
        
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupName...", nil)];
        [[EMClient sharedClient].groupManager updateGroupSubject:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"updateGroupSubjectFail", nil)];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateGroupDetailAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.group.description placeholder:NSLocalizedString(@"inputGroupDescription", nil) isEditable:isEditable];
    if (isEditable) {
         controller.title = NSLocalizedString(@"editGroupDescription", nil);
    } else {
        controller.title = NSLocalizedString(@"groupDescription", nil);
    }
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupDescription...", nil)];
        [[EMClient sharedClient].groupManager updateDescription:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"updateGroupDescriptionFail", nil)];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateGroupOnwerAction
{
    if (self.group.permissionType != EMGroupPermissionTypeOwner) {
        return;
    }
    
    EMGroupOwnerViewController *controller = [[EMGroupOwnerViewController alloc] initWithGroup:self.group];
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(EMGroup * _Nonnull aGroup) {
        [weakself _resetGroup:aGroup];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_leaveOrDestroyGroupAction
{
    __weak typeof(self) weakself = self;
    void (^block)(EMError *aError) = ^(EMError *aError) {
        if (!aError && [EMClient sharedClient].options.isDeleteMessagesWhenExitGroup) {
            [[EMClient sharedClient].chatManager deleteServerConversation:weakself.groupId conversationType:EMConversationTypeGroupChat isDeleteServerMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                if (aError) {
                    [weakself showHint:aError.errorDescription];
                }
                
                [[EMClient sharedClient].chatManager deleteConversation:weakself.groupId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                    
                }];
            }];
        }
        [weakself hideHud];
        [weakself.navigationController popViewControllerAnimated:YES];
        if (weakself.leaveOrDestroyCompletion) {
            weakself.leaveOrDestroyCompletion();
        }
    };
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        [self showHudInView:self.view hint:NSLocalizedString(@"destroyGroup...", nil)];
        [[EMClient sharedClient].groupManager destroyGroup:self.groupId finishCompletion:block];
    } else {
        [self showHudInView:self.view hint:NSLocalizedString(@"leaveGroup...", nil)];
        [[EMClient sharedClient].groupManager leaveGroup:self.groupId completion:block];
    }
}

- (void)addMemberAction
{
    __weak typeof(self) weakself = self;
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            weakself.group = aGroup;
            [weakself _resetGroup:aGroup];
            NSMutableArray *occupants = [[NSMutableArray alloc] init];
            [occupants addObject:weakself.group.owner];
            [occupants addObjectsFromArray:weakself.group.adminList];
            [occupants addObjectsFromArray:weakself.group.memberList];
            EMInviteGroupMemberViewController *controller = [[EMInviteGroupMemberViewController alloc] initWithBlocks:occupants];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            navController.modalPresentationStyle = 0;
            [self presentViewController:navController animated:YES completion:nil];
            
            [controller setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
                [weakself showHudInView:weakself.view hint:NSLocalizedString(@"addMember", nil)];
                [[EMClient sharedClient].groupManager addMembers:aSelectedArray toGroup:weakself.groupId message:@"" completion:^(EMGroup *aGroup, EMError *aError) {
                    [weakself hideHud];
                    if (aError) {
                        [EMAlertController showErrorAlert:aError.errorDescription];
                    } else {
                        [weakself _fetchGroupWithId:weakself.groupId isShowHUD:NO];
                    }
                }];
            }];
        } else {
            [EMAlertController showErrorAlert:[NSString stringWithFormat:NSLocalizedString(@"fetchGroupSubjectFail", nil),aError.description]];
        }
    }];
}
    
#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

//string TO dictonary
- (NSMutableDictionary *)changeStringToDictionary:(NSString *)string{

    if (string) {
        NSMutableDictionary *returnDic = [[NSMutableDictionary  alloc]  init];
        returnDic = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return returnDic;
    }
    return nil;
}


@end
