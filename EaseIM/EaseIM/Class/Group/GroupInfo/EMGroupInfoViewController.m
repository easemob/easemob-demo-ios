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

#import "BQTitleAvatarCell.h"
#import "BQTitleValueAccessCell.h"
#import "BQTitleValueCell.h"
#import "BQTitleSwitchCell.h"
#import "BQGroupMemberCell.h"
#import "BQAddGroupMemberViewController.h"
#import "EMInviteGroupMemberViewController.h"
#import "BQChatRecordContainerViewController.h"
#import "BQTitleAvatarAccessCell.h"
#import "YGGroupMuteSettingViewController.h"


@interface EMGroupInfoViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) EMAvatarNameCell *addMemberCell;
@property (nonatomic, strong) UITableViewCell *leaveCell;
@property (nonatomic, strong) UILabel *leaveCellContentLabel;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;


@property (nonatomic, strong) BQGroupMemberCell *groupMemberCell;

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
    
    [self registeCell];
    [self _setupSubviews];
//    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    self.showRefreshHeader = NO;
    [self _fetchGroupWithId:self.groupId isShowHUD:YES];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInfo) name:GROUP_INFO_REFRESH object:nil];
}

- (void)registeCell {
    
    [self.tableView registerClass:[BQTitleAvatarCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarCell class])];
    [self.tableView registerClass:[BQTitleValueAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
    [self.tableView registerClass:[BQTitleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleSwitchCell class])];
    [self.tableView registerClass:[BQTitleValueCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueCell class])];

    [self.tableView registerClass:[BQTitleAvatarAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarAccessCell class])];
    
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
    self.title = @"群设置";
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    }else if (section == 1){
#if kJiHuApp
        return 4;
#else
        if (self.group.permissionType == EMGroupPermissionTypeOwner) {
            return 6;
        } else {
            return 5;
        }
#endif
        return 4;
    }else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BQTitleAvatarCell *titleAvatarCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleAvatarCell reuseIdentifier]];
    
    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];

    BQTitleValueCell *titleValueCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueCell reuseIdentifier]];

    BQTitleSwitchCell *titleSwitchCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleSwitchCell reuseIdentifier]];

    BQTitleAvatarAccessCell *titleAvatarAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleAvatarAccessCell reuseIdentifier]];
    
    
    if (indexPath.section == 0) {
#if kJiHuApp
        if (indexPath.row == 0) {
            titleAvatarCell.nameLabel.text = @"群头像";
            [titleAvatarCell.iconImageView setImage:ImageWithName(@"jh_group_icon")];
            return titleAvatarCell;
        }else {
            [self.groupMemberCell updateWithObj:self.group];
            return self.groupMemberCell;
        }
#else
        if (indexPath.row == 0) {
            if (self.group.permissionType == EMGroupPermissionTypeOwner) {
                titleAvatarAccessCell.nameLabel.text = @"群头像";
                [titleAvatarAccessCell.iconImageView setImage:ImageWithName(@"jh_group_icon")];
                return titleAvatarAccessCell;
                
            }else {
                titleAvatarCell.nameLabel.text = @"群头像";
                [titleAvatarCell.iconImageView setImage:ImageWithName(@"jh_group_icon")];
                return titleAvatarCell;
            }
        }else {
            [self.groupMemberCell updateWithObj:self.group];
            return self.groupMemberCell;
        }
#endif
       
    }else if (indexPath.section == 1){
#if kJiHuApp
        if (indexPath.row == 0) {
            titleValueCell.nameLabel.text = @"群名称";
            titleValueCell.detailLabel.text = self.group.groupName;
            return titleValueCell;
        }else if (indexPath.row == 1){
            titleValueCell.nameLabel.text = @"群主";
            titleValueCell.detailLabel.text = self.group.owner;
            return titleValueCell;

        }else if (indexPath.row == 2){
            titleValueAccessCell.nameLabel.text = @"群公告";
            titleValueAccessCell.detailLabel.text = @"";
            titleValueAccessCell.tapCellBlock = ^{
                [self groupAnnouncementAction];
            };
            return titleValueAccessCell;
        }else {
            titleValueAccessCell.nameLabel.text = @"群介绍";
            titleValueAccessCell.detailLabel.text = @"";
            titleValueAccessCell.tapCellBlock = ^{
                [self _updateGroupDetailAction];
            };
            return titleValueAccessCell;
        }
#else
        if (self.group.permissionType == EMGroupPermissionTypeOwner) {
            if (indexPath.row == 0) {
                titleValueAccessCell.nameLabel.text = @"群名称";
                titleValueAccessCell.detailLabel.text = self.group.groupName;
                titleValueAccessCell.tapCellBlock = ^{
                    [self _updateGroupNameAction];
                };
                return titleValueAccessCell;
            }else if (indexPath.row == 1){
                titleValueCell.nameLabel.text = @"群主";
                titleValueCell.detailLabel.text = self.group.owner;
                return titleValueCell;

            }else if (indexPath.row == 2){
                titleValueAccessCell.nameLabel.text = @"群公告";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self groupAnnouncementAction];
                };
                return titleValueAccessCell;
            }else  if (indexPath.row == 3){
                titleValueAccessCell.nameLabel.text = @"群介绍";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self _updateGroupDetailAction];
                };
                return titleValueAccessCell;
            }else if (indexPath.row == 4){
                titleValueAccessCell.nameLabel.text = @"群禁言";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self goSettingMutePage];
                };
                return titleValueAccessCell;
            }else {
                titleValueAccessCell.nameLabel.text = @"运营备注";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self _updateGroupDetailAction];
                };
                return titleValueAccessCell;
            }

        } else {
            if (indexPath.row == 0) {
                titleValueCell.nameLabel.text = @"群名称";
                titleValueCell.detailLabel.text = self.group.groupName;
                return titleValueCell;
            }else if (indexPath.row == 1){
                titleValueCell.nameLabel.text = @"群主";
                titleValueCell.detailLabel.text = self.group.owner;
                return titleValueCell;

            }else if (indexPath.row == 2){
                titleValueAccessCell.nameLabel.text = @"群公告";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self groupAnnouncementAction];
                };
                return titleValueAccessCell;
            }else  if (indexPath.row == 3){
                titleValueAccessCell.nameLabel.text = @"群介绍";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self _updateGroupDetailAction];
                };
                return titleValueAccessCell;
            }else {
                titleValueAccessCell.nameLabel.text = @"运营备注";
                titleValueAccessCell.detailLabel.text = @"";
                titleValueAccessCell.tapCellBlock = ^{
                    [self _updateGroupDetailAction];
                };
                return titleValueAccessCell;
            }
        }


#endif

        
    }else {
        if (indexPath.row == 0) {
            titleValueAccessCell.nameLabel.text = @"查找聊天内容";
            titleValueAccessCell.detailLabel.text = @"";
            titleValueAccessCell.tapCellBlock = ^{
                [self goSearchChatRecord];
            };
            return titleValueAccessCell;
        }else {
            titleSwitchCell.nameLabel.text = @"消息免打扰";
            [titleSwitchCell.aSwitch setOn:self.group.isPushNotificationEnabled];
            BQ_WS
            titleSwitchCell.switchActionBlock = ^(UISwitch * _Nonnull aSwitch) {
                [weakSelf noDisturbEnableWithSwitch:aSwitch];
            };
            
            return titleSwitchCell;
        }
    }
    return nil;
}
 

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1){
        return [BQGroupMemberCell cellHeightWithObj:self.group];
    }
    
    return 64.0;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];
#if kJiHuApp
    hView.backgroundColor = ViewBgBlackColor;
#else
    hView.backgroundColor = ViewBgWhiteColor;
#endif

    return hView;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    if (section == 0) {
//        if (row == 1) {
//            //群成员
//            EMGroupAllMembersViewController *controller = [[EMGroupAllMembersViewController alloc]initWithGroup:self.group];
//            [self.navigationController pushViewController:controller animated:YES];
//        } else if (row == 2) {
//            //邀请成员
//            [self addMemberAction];
//        }
//    } else if (section == 1) {
//        if (row == 0) {
//             //修改群名称
//            [self _updateGroupNameAction];
//        } else if (row == 1) {
//            //群共享文件
//            EMGroupSharedFilesViewController *controller = [[EMGroupSharedFilesViewController alloc] initWithGroup:self.group];
//            [self.navigationController pushViewController:controller animated:YES];
//        } else if (row == 2) {
//            [self groupAnnouncementAction];
//        } else if (row == 3) {
//            //群介绍
//            [self _updateGroupDetailAction];
//        } else if (row == 4) {
//            //群管理
//            EMGroupManageViewController *controller = [[EMGroupManageViewController alloc]initWithGroup:self.groupId];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    } else if (section == 2) {
//        if (row == 0) {
//            //查找聊天记录
//            [self goSearchChatRecord];
//        }
//    } else if (section == 4) {
//        //删除聊天记录
//        [self deleteGroupRecord];
//    } else if (section == 5) {
//        if (row == 0) {
//            [self _leaveOrDestroyGroupAction];
//        }
//    }
//}

- (void)goSearchChatRecord {
    //查找聊天记录
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
    BQChatRecordContainerViewController *chatRrcordController = [[BQChatRecordContainerViewController alloc]initWithCoversationModel:conversation];
  
    [self.navigationController pushViewController:chatRrcordController animated:YES];
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
- (void)noDisturbEnableWithSwitch:(UISwitch *)aSwitch {
    
    BQ_WS
    [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
    [EMClient.sharedClient.groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:!aSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            weakSelf.group = aGroup;
        } else {
            if (aError) {
                [weakSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
                [aSwitch setOn:NO];
            }
        }
    }];
}


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
            controller.title = @"群公告";
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupAnn...", nil)];
                [[EMClient sharedClient].groupManager updateGroupAnnouncementWithId:weakself.groupId announcement:aString completion:^(EMGroup *aGroup, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
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
                    [[EMTranslationManager sharedManager] removeTranslationByConversationId:weakself.groupId];
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

#pragma mark getter and setter
- (BQGroupMemberCell *)groupMemberCell {
    if (_groupMemberCell == nil) {
        _groupMemberCell =  [[BQGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[BQGroupMemberCell reuseIdentifier]];
        
        BQ_WS
        _groupMemberCell.addMemberBlock = ^{
            [weakSelf goAddGroupMemberPage];
        };
        
        _groupMemberCell.moreMemberBlock = ^{
            [weakSelf goCheckGroupMemberPage];
        };
        
    }
    return _groupMemberCell;
}

- (void)goAddGroupMemberPage {
    BQAddGroupMemberViewController *controller = [[BQAddGroupMemberViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)goCheckGroupMemberPage {
    EMGroupMembersViewController *controller = [[EMGroupMembersViewController alloc]initWithGroup:self.group];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goSettingMutePage {
    YGGroupMuteSettingViewController *controller = [[YGGroupMuteSettingViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
