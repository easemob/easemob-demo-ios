//
//  EMChatroomInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomInfoViewController.h"

#import "EMTextViewController.h"
#import "EMTextFieldViewController.h"
#import "EMChatroomOwnerViewController.h"
#import "EMChatroomMembersViewController.h"
#import "EMChatroomAdminsViewController.h"
#import "EMChatroomMutesViewController.h"

@interface EMChatroomInfoViewController ()<EMChatroomManagerDelegate>

@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic) BOOL isOwner;
@property (nonatomic, strong) UITableViewCell *dissolveCell;
@property (nonatomic, strong) UILabel *dissolveCellContentLabel;

@end

@implementation EMChatroomInfoViewController

- (instancetype)initWithChatroomId:(NSString *)aChatroomId
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _chatroomId = aChatroomId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
    
    [self _fetchChatroomWithId:self.chatroomId isShowHUD:YES];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatroomInfoUpdated:) name:CHATROOM_INFO_UPDATED object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(chatroomAnnouncementAction)];
    self.title = NSLocalizedString(@"chatroomDescription", nil);
    
    self.showRefreshHeader = YES;
    self.dissolveCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefaultRedFont"];
    self.dissolveCellContentLabel = [[UILabel alloc]init];
    self.dissolveCellContentLabel.text = NSLocalizedString(@"destroyChatroom", nil);
    self.dissolveCellContentLabel.textColor = [UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0];
    self.dissolveCellContentLabel.font = [UIFont systemFontOfSize:18.0];
    [self.dissolveCell.contentView addSubview:self.dissolveCellContentLabel];
    [self.dissolveCellContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.dissolveCell.contentView);
    }];
    self.dissolveCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, [UIScreen mainScreen].bounds.size.width);
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chatroom.owner isEqualToString:EMClient.sharedClient.currentUsername]) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    } else if (section == 1) {
        count = 1;
    } else if (section == 2) {
        count = 1;
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            count = 2;
        }
    } else if (section == 3) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"chatroomId...", nil);
            cell.detailTextLabel.text = self.chatroom.chatroomId;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"subject", nil);
            cell.detailTextLabel.text = self.chatroom.subject;
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 2) {
            cell.textLabel.text = NSLocalizedString(@"description", nil);
            cell.detailTextLabel.text = self.chatroom.description;
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 3) {
            cell.textLabel.text = NSLocalizedString(@"owner", nil);
            cell.detailTextLabel.text = self.chatroom.owner;
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"chatroomMembers", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)self.chatroom.occupantsCount];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Admins", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"counts", nil),@([self.chatroom.adminList count] + 1).stringValue];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"mutes", nil);
            cell.detailTextLabel.text = @([self.chatroom.muteList count]).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 3) {
        return self.dissolveCell;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 40;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            [self _updateChatroomNameAction];
        } else if (row == 2) {
            [self _updateChatroomDetailAction];
        } else if (row == 3) {
            [self _updateChatroomOnwerAction];
        }
    } else if (section == 1) {
        if (row == 0) {
            EMChatroomMembersViewController *controller = [[EMChatroomMembersViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            EMChatroomAdminsViewController *controller = [[EMChatroomAdminsViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMChatroomMutesViewController *controller = [[EMChatroomMutesViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 3) {
        [self _dissolveChatroomAction];
    }
}

#pragma mark - EMChatroomManagerDelegate

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.dissolveCompletion) {
        self.dissolveCompletion();
    }
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    [self _resetChatroom:aChatroom];
}

#pragma mark - Data

- (void)_resetChatroom:(EMChatroom *)aChatroom
{
    self.chatroom = aChatroom;
    [self.tableView reloadData];
}

- (void)_fetchChatroomWithId:(NSString *)aChatroomId
                   isShowHUD:(BOOL)aIsShowHUD
{
    __weak typeof(self) weakself = self;
    
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchChatroomSubject", nil)];
    }
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:aChatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aChatroom) {
            weakself.chatroom = aChatroom;
            weakself.chatroomId = aChatroom.chatroomId;
            weakself.isOwner = [aChatroom.owner isEqualToString:[EMClient sharedClient].currentUsername] ? YES : NO;
            [weakself.tableView reloadData];
        } else if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"fetchChatroomFail", nil)];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchChatroomWithId:self.chatroomId isShowHUD:NO];
}

#pragma mark - NSNotification

- (void)handleChatroomInfoUpdated:(NSNotification *)aNotif
{
    EMChatroom *chatroom = aNotif.object;
    if (!chatroom || ![chatroom.chatroomId isEqualToString:self.chatroomId]) {
        return;
    }
    
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - Action

- (void)_dissolveChatroomAction
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager destroyChatroom:self.chatroomId completion:^(EMError *aError) {
        if (!aError) {
            [weakself.navigationController popViewControllerAnimated:YES];
            if (weakself.dissolveCompletion) {
                weakself.dissolveCompletion();
            }
        } else {
            [EMAlertController showErrorAlert:aError.errorDescription];
        }
    }];
}

- (void)chatroomAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchChatroomAnn...", nil)];
    [[EMClient sharedClient].roomManager getChatroomAnnouncementWithId:self.chatroomId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            BOOL isEditable = weakself.isOwner;
            if (!isEditable) {
                isEditable = [weakself.chatroom.adminList containsObject:[EMClient sharedClient].currentUsername];
            }
            EMTextViewController *controller = [[EMTextViewController alloc] initWithString:aAnnouncement placeholder:NSLocalizedString(@"inputChatroomAnnounment", nil) isEditable:isEditable];
            controller.title = NSLocalizedString(@"chatroomAnnounment", nil);
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateChatroomAnn...", nil)];
                [[EMClient sharedClient].roomManager updateChatroomAnnouncementWithId:weakself.chatroomId announcement:aString completion:^(EMChatroom *aChatroom, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
                        [EMAlertController showErrorAlert:NSLocalizedString(@"upateChatroomAnnounmentFail", nil)];
                    } else {
                        [weakController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
                return NO;
            }];
            
            [weakself.navigationController pushViewController:controller animated:YES];
        } else {
            [EMAlertController showErrorAlert:NSLocalizedString(@"upateChatroomAnnounmentSuccess", nil)];
        }
    }];
}

- (void)_updateChatroomNameAction
{
    BOOL isEditable = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? YES : NO;
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.chatroom.subject placeholder:NSLocalizedString(@"inputchatroomSubject", nil) isEditable:isEditable];
    controller.title = NSLocalizedString(@"chatroomSubject", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"emptyChatroomSubject", nil)];
            return NO;
        }
        
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateChatroomName...", nil)];
        [[EMClient sharedClient].roomManager updateSubject:aString forChatroom:weakself.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetChatroom:aChatroom];
                [weakController.navigationController popViewControllerAnimated:YES];
                [NSNotificationCenter.defaultCenter postNotificationName:CHATROOM_INFO_UPDATED object:nil];
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"updateChatroomSubjectFail", nil)];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateChatroomDetailAction
{
    BOOL isEditable = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? YES : NO;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.chatroom.description placeholder:NSLocalizedString(@"chatroomDescription", nil) isEditable:isEditable];
    controller.title = NSLocalizedString(@"chatroomDescription", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateChatroomDescription...", nil)];
        [[EMClient sharedClient].roomManager updateDescription:aString forChatroom:weakself.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetChatroom:aChatroom];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"updateChatroomDescriptionFail", nil)];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateChatroomOnwerAction
{
    if (self.chatroom.permissionType != EMChatroomPermissionTypeOwner) {
        return;
    }
    
    EMChatroomOwnerViewController *controller = [[EMChatroomOwnerViewController alloc] initWithChatroom:self.chatroom];
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(EMChatroom * _Nonnull aChatroom) {
        [weakself _resetChatroom:aChatroom];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
