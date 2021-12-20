//
//  EMCreateGroupViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMCreateGroupViewController.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"
#import "EMInviteGroupMemberViewController.h"

@interface EMCreateGroupViewController ()

@property (nonatomic, strong) NSMutableArray *members;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UITableViewCell *nameCell;

@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) UITableViewCell *detailCell;
@property (nonatomic, strong) UITableViewCell *contentCell;

@property (nonatomic) NSInteger maxMemNum;
@property (nonatomic, strong) UITableViewCell *memberNumCell;

@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) UITableViewCell *publicCell;

@property (nonatomic) BOOL isNeedApply;
@property (nonatomic) BOOL isMemberCanInvite;
@property (nonatomic, strong) UITableViewCell *optionCell;

@property (nonatomic, strong) UITableViewCell *inviteCountCell;


@end

@implementation EMCreateGroupViewController

- (instancetype)initWithSelectedMembers:(NSArray *)aMembers
{
    self = [super init];
    if (self) {
        self.members = [[NSMutableArray alloc] initWithArray:aMembers];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.maxMemNum = 200;
    [self _setupSubviews];
    
    if (self.inviteController) {
        __weak typeof(self) weakself = self;
        [self.inviteController setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
            [weakself.members removeAllObjects];
            [weakself.members addObjectsFromArray:aSelectedArray];
            weakself.inviteCountCell.detailTextLabel.text = @([weakself.members count]).stringValue;
        }];
    }
}

- (void)dealloc
{
//    _successCompletion = nil;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(createGroupAction)];
    self.title = NSLocalizedString(@"createGroup", nil);
    
    self.tableView.backgroundColor = kColor_LightGray;
    
    self.nameCell = [self _setupValue1CellWithName:NSLocalizedString(@"subject", nil) detail:NSLocalizedString(@"needGroupSubject", nil)];
    
    self.detailCell = [self _setupValue1CellWithName:NSLocalizedString(@"description", nil) detail:NSLocalizedString(@"inputGroupDescription", nil)];
    self.detailCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
    self.contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
    self.contentCell.textLabel.numberOfLines = 5;
    self.contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentCell.textLabel.textColor = [UIColor grayColor];
    
    self.memberNumCell = [self _setupValue1CellWithName:NSLocalizedString(@"memberCount", nil) detail:@(self.maxMemNum).stringValue];
    self.publicCell = [self _setupSwitchCellWithName:NSLocalizedString(@"isPublic", nil) action:@selector(publicSwitchValueChanged:)];
    self.optionCell = [self _setupSwitchCellWithName:NSLocalizedString(@"memberRight", nil) action:@selector(optionSwitchValueChanged:)];
    self.inviteCountCell = [self _setupValue1CellWithName:NSLocalizedString(@"members", nil) detail:@([self.members count]).stringValue];
}

- (UITableViewCell *)_setupValue1CellWithName:(NSString *)aName
                                       detail:(NSString *)aDetail
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = aName;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = aDetail;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (UITableViewCell *)_setupSwitchCellWithName:(NSString *)aName
                                       action:(SEL)aAction
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = aName;
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
    [sw addTarget:self action:aAction forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    } else {
        count = 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            cell = self.nameCell;
        } else if (row == 1) {
            cell = self.detailCell;
        } else if (row == 2) {
            cell = self.contentCell;
        } else if (row == 3) {
            cell = self.memberNumCell;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell = self.publicCell;
        }
    } else if (section == 2) {
        if (row == 0) {
            cell = self.optionCell;
        }
    } else if (section == 3) {
        if (row == 0) {
            cell = self.inviteCountCell;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 100;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        if (section == 1) {
            label.text = self.isPublic ? NSLocalizedString(@"othersFindGroup", nil) : NSLocalizedString(@"othersCannotFindGroup",nil);
        } else if (section == 2) {
            if (self.isPublic) {
                label.text = self.isNeedApply ? NSLocalizedString(@"joinNeedOwnerAgre", nil) : NSLocalizedString(@"directJoin",nil);
            } else {
                label.text = self.isMemberCanInvite ? NSLocalizedString(@"allowMembersInvite", nil) : NSLocalizedString(@"onlyOwnerInvite",nil);
            }
        }
        
        return label;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [self _updateName];
        } else if (row == 1 || row == 2) {
            [self _updateDetail];
        } else if (row == 3) {
            [self _updateMaxMemberNum];
        }
    } else if (section == 3) {
        if (row == 0) {
            [self _updateInviteMembers];
        }
    }
}

#pragma mark - Action

- (void)_updateName
{
    __weak typeof(self) weakself = self;
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.name placeholder:NSLocalizedString(@"needGroupSubject", nil) isEditable:YES];
    controller.title = NSLocalizedString(@"groupSubject", nil);
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        weakself.name = aString;
        if ([aString length] > 0) {
            weakself.nameCell.detailTextLabel.text = aString;
        } else {
            weakself.nameCell.detailTextLabel.text = NSLocalizedString(@"inputGroupSubject", nil);
        }
        return YES;
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_updateDetail
{
    __weak typeof(self) weakself = self;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.detail placeholder:NSLocalizedString(@"inputGroupDescription", nil) isEditable:YES];
    controller.title = NSLocalizedString(@"groupDescritption", nil);
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        weakself.detail = aString;
        if ([aString length] > 0) {
            weakself.detailCell.detailTextLabel.text = nil;
            weakself.contentCell.textLabel.text = aString;
        } else {
            weakself.detailCell.detailTextLabel.text = NSLocalizedString(@"inputGroupDescription", nil);
            weakself.contentCell.textLabel.text = nil;
        }
        return YES;
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_updateMaxMemberNum
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"memberCount", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"inputGroupMemCount", nil);
        textField.text = @(self.maxMemNum).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSInteger value = [textField.text integerValue];
        if (value > 2 && value < 3001) {
            self.maxMemNum = value;
            self.memberNumCell.detailTextLabel.text = @(value).stringValue;
        } else {
            [EMAlertController showErrorAlert:NSLocalizedString(@"groupMemberCounts", nil)];
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)_updateInviteMembers
{
    if (!self.inviteController) {
        self.inviteController = [[EMInviteGroupMemberViewController alloc] init];
        __weak typeof(self) weakself = self;
        [self.inviteController setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
            [weakself.members removeAllObjects];
            [weakself.members addObjectsFromArray:aSelectedArray];
            weakself.inviteCountCell.detailTextLabel.text = @([weakself.members count]).stringValue;
        }];
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.inviteController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)publicSwitchValueChanged:(UISwitch *)aSwitch
{
    self.isPublic = aSwitch.isOn;
    
    self.optionCell.textLabel.text = self.isPublic ? NSLocalizedString(@"joinNeedAllow", nil) : NSLocalizedString(@"memberRight", nil);
    UISwitch *sw = (UISwitch *)self.optionCell.accessoryView;
    [sw setOn:NO];
    if (!self.isPublic)
        self.isMemberCanInvite = NO;
    
    [self.tableView reloadData];
}

- (void)optionSwitchValueChanged:(UISwitch *)aSwitch
{
    if (self.isPublic) {
        self.isNeedApply = aSwitch.isOn;
    } else {
        self.isMemberCanInvite = aSwitch.isOn;
    }
    [self.tableView reloadData];
}

- (void)createGroupAction
{
    if ([self.name length] == 0) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"inputGroupSubject", nil)];
        return;
    }
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"creatGroup...", nil)];
    EMGroupOptions *options = [[EMGroupOptions alloc] init];
    options.maxUsersCount = self.maxMemNum;
    if (self.isPublic) {
        if (self.isNeedApply) {
            options.style = EMGroupStylePublicJoinNeedApproval;
        } else {
            options.style = EMGroupStylePublicOpenJoin;
        }
    } else {
        if (self.isMemberCanInvite) {
            options.style = EMGroupStylePrivateMemberCanInvite;
        } else {
            options.style = EMGroupStylePrivateOnlyOwnerInvite;
        }
    }
    
    [[EMClient sharedClient].groupManager createGroupWithSubject:self.name description:self.detail invitees:self.members message:nil setting:options completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"createGroupFail", nil)];
        } else {
            [EMAlertController showSuccessAlert:NSLocalizedString(@"createGroupSucess", nil)];
            [weakself.navigationController popViewControllerAnimated:YES];
            if (weakself.successCompletion) {
                weakself.successCompletion(aGroup);
            }
        }
    }];
}

@end
