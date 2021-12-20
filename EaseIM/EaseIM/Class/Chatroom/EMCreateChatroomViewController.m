//
//  EMCreateChatroomViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMCreateChatroomViewController.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"

@interface EMCreateChatroomViewController ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UITableViewCell *nameCell;

@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) UITableViewCell *detailCell;
@property (nonatomic, strong) UITableViewCell *contentCell;

@property (nonatomic) NSInteger maxMemNum;
@property (nonatomic, strong) UITableViewCell *memberNumCell;

@end

@implementation EMCreateChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.maxMemNum = 200;
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"commit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(createChatroomAction)];
    self.title = NSLocalizedString(@"createChatroom", nil);
    
    self.tableView.backgroundColor = kColor_LightGray;
    
    self.nameCell = [self _setupValue1CellWithName:NSLocalizedString(@"subject", nil) detail:NSLocalizedString(@"inputchatroomSubject", nil)];
    
    self.detailCell = [self _setupValue1CellWithName:NSLocalizedString(@"description", nil) detail:NSLocalizedString(@"chatroomDescription", nil)];
    self.detailCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
    self.contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
    self.contentCell.textLabel.numberOfLines = 5;
    self.contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentCell.textLabel.textColor = [UIColor grayColor];
    
    self.memberNumCell = [self _setupValue1CellWithName:NSLocalizedString(@"chatroomMembers", nil) detail:@(self.maxMemNum).stringValue];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    if (row == 0) {
        cell = self.nameCell;
    } else if (row == 1) {
        cell = self.detailCell;
    } else if (row == 2) {
        cell = self.contentCell;
    } else if (row == 3) {
        cell = self.memberNumCell;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 100;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    __weak typeof(self) weakself = self;
    if (row == 0) {
        EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.name placeholder:NSLocalizedString(@"inputchatroomSubject", nil) isEditable:YES];
        controller.title = NSLocalizedString(@"chatroomSubject", nil);
        [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
            weakself.name = aString;
            if ([aString length] > 0) {
                self.nameCell.detailTextLabel.text = aString;
            } else {
                self.nameCell.detailTextLabel.text = NSLocalizedString(@"inputchatroomSubject", nil);
            }
            
            return YES;
        }];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 1 || row == 2) {
        EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.detail placeholder:NSLocalizedString(@"chatroomDescription", nil) isEditable:YES];
        controller.title = NSLocalizedString(@"chatroomDescription", nil);
        [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
            weakself.detail = aString;
            if ([aString length] > 0) {
                self.detailCell.detailTextLabel.text = nil;
                self.contentCell.textLabel.text = aString;
            } else {
                self.detailCell.detailTextLabel.text = NSLocalizedString(@"chatroomDescription", nil);
                self.contentCell.textLabel.text = nil;
            }
            return YES;
        }];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 3) {
        [self updateMaxMemberNum];
    }
}

#pragma mark - Action

- (void)createChatroomAction
{
    if ([self.name length] == 0) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"inputchatroomSubject", nil)];
        return;
    }
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"createChatroom...", nil)];
    [[EMClient sharedClient].roomManager createChatroomWithSubject:self.name description:self.detail invitees:nil message:nil maxMembersCount:self.maxMemNum completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"createChatroomFail", nil)];
        } else {
            if (weakself.successCompletion) {
                weakself.successCompletion(aChatroom);
            }
            [EMAlertController showSuccessAlert:NSLocalizedString(@"createChatroomSuccess", nil)];
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)updateMaxMemberNum
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"chatroomMembers", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"chatroomMembrCounts", nil);
        textField.text = @(self.maxMemNum).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSInteger value = [textField.text integerValue];
        if (value > 2 && value < 1001) {
            self.maxMemNum = value;
            self.memberNumCell.detailTextLabel.text = @(value).stringValue;
        } else {
            [EMAlertController showErrorAlert:NSLocalizedString(@"inputChatroomMembrCounts", nil)];
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
