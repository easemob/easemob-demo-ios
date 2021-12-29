//
//  EMPersonalDataViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/10.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMPersonalDataViewController.h"
#import "EMChatViewController.h"
#import "EMAvatarNameCell+UserInfo.h"
#import "PellTableViewSelect.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EMPersonalDataViewController ()

@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSArray *contacts;

@property (nonatomic, strong) UILabel *funLabel;

@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) EMChatViewController *chatController;
@property (nonatomic) BOOL isChatting;
@end


@implementation EMPersonalDataViewController

- (instancetype)initWithNickName:(NSString *)aNickName
{
    self = [super init];
    if (self) {
        _nickName = aNickName;
        _contacts = [[EMClient sharedClient].contactManager getContacts];
        _hint = NSLocalizedString(@"addContact", nil);
    }
    return self;
}

- (instancetype)initWithNickName:(NSString *)aNickName isChatting:(BOOL)isChatting;
{
    self = [super init];
    if (self) {
        _nickName = aNickName;
        _contacts = [[EMClient sharedClient].contactManager getContacts];
        _isChatting = isChatting;
        _hint = NSLocalizedString(@"addContact", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    self.showRefreshHeader = NO;
    [self _setupSubviews];
    [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[self.nickName]];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.chatController];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = NSLocalizedString(@"personalInfo", nil);
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    if ([self.contacts containsObject:self.nickName])
        [self _setupNavigationBarRightItem];

    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        if ([self.contacts containsObject:self.nickName])
            make.height.equalTo(@324);
        else
            make.height.equalTo(@152);
    }];
}

- (void)_setupNavigationBarRightItem
{
    UIImage *image = [[UIImage imageNamed:@"icon-setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addBlackListView)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.contacts containsObject:self.nickName]) {
        return 5;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSString *cellIdentifier = @"UITableViewCellValue1";

    if (section == 0) {
        EMAvatarNameCell *cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
        cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        cell.nameLabel.text = self.nickName;
        [cell refreshUserInfo:self.nickName];
        
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.funLabel = [[UILabel alloc]init];
    self.funLabel.userInteractionEnabled = NO;
    self.funLabel.font = [UIFont systemFontOfSize:18.0];
    self.funLabel.textColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
    
    if (section == 1)
        self.funLabel.text = [self.contacts containsObject:self.nickName] ? @"" : self.hint;
    if (section == 2)
        self.funLabel.text = NSLocalizedString(@"sendMsg", nil);
    if (section == 3)
        self.funLabel.text = NSLocalizedString(@"audioCall", nil);
    if (section == 4 )
        self.funLabel.text = NSLocalizedString(@"videoCall", nil);
    
    [cell.contentView addSubview:self.funLabel];
    [self.funLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cell.contentView);
    }];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && [self.contacts containsObject:self.nickName])
        return 0;
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || (section == 1 && [self.contacts containsObject:self.nickName]))
        return 0.001;
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    self.chatController = [[EMChatViewController alloc]initWithConversationId:self.nickName conversationType:EMConversationTypeChat];
    if (section == 1)
        //添加联系人
        [self addContact];
    if (section == 2) {
        //聊天
        if (self.isChatting) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController pushViewController:self.chatController animated:YES];
        }
    }
    if (section == 3) {
        //语音通话
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:self.nickName, CALL_TYPE:@(EaseCallType1v1Audio)}];
        if (!self.isChatting)
            [[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(insertLocationCallRecord:) name:EMCOMMMUNICATE_RECORD object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(sendCallEndMsg:) name:EMCOMMMUNICATE object:nil];
    }
    if (section == 4) {
        //视频通话
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:self.nickName, CALL_TYPE:@(EaseCallType1v1Video)}];
        if (!self.isChatting)
            [[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(insertLocationCallRecord:) name:EMCOMMMUNICATE_RECORD object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(sendCallEndMsg:) name:EMCOMMMUNICATE object:nil];
    }
}

//黑名单view
- (void)addBlackListView
{
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-180, self.navigationController.navigationBar.frame.size.height + 30, 165, 52) selectData:@[NSLocalizedString(@"addBlacklist", nil)] images:@[@""] locationY:30 + EMVIEWTOPMARGIN action:^(NSInteger index){
        if(index == 0) {
            [self addContactToBlackList];
        }
    } animated:YES];
}
#pragma mark - Action

//添加黑名单
- (void)addContactToBlackList
{
    if ([[self getchBlackList] containsObject:self.nickName]) {
        [self showHint:NSLocalizedString(@"inBlackList", nil)];
        return;
    }
    [self showHudInView:self.view hint:NSLocalizedString(@"blUser...", nil)];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addUserToBlackList:self.nickName completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (!aError)
            [EMAlertController showSuccessAlert:NSLocalizedString(@"blackSucess", nil)];
        else
            [EMAlertController showErrorAlert:NSLocalizedString(@"blackFail", nil)];
        if (!aError)
            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_UPDATE object:nil];
    }];
}

//添加联系人
- (void)addContact
{
    [self showHudInView:self.view hint:NSLocalizedString(@"inviteContact...", nil)];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addContact:self.nickName message:nil completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            if (aError.code == EMErrorContactReachLimit) {
                [EMAlertController showErrorAlert:NSLocalizedString(@"applyfail.ContactReachLimit", nil)];
            } else if (aError.code == EMErrorContactReachLimitPeer) {
                [EMAlertController showErrorAlert:NSLocalizedString(@"applyfail.ContactReachLimitPeer", nil)];
            } else {
                [EMAlertController showErrorAlert:NSLocalizedString(@"applyfail", nil)];
            }
            return;
        }
        self.hint = NSLocalizedString(@"applied", nil);
        [self.tableView reloadData];
        [EMAlertController showSuccessAlert:NSLocalizedString(@"sendInvite", nil)];
    }];
}

//获取黑名单
- (NSArray *)getchBlackList
{
    return [[EMClient sharedClient].contactManager getBlackList];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

@end
