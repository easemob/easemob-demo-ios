//
//  CallSettingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 06/12/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "CallSettingViewController.h"

#import "SingleCallController.h"
#import "CallResolutionViewController.h"

#define FIXED_BITRATE_ALERTVIEW_TAG 100
#define AUTO_MAXRATE_ALERTVIEW_TAG 99
#define AUTO_MINKBPS_ALERTVIEW_TAG 98

@interface CallSettingViewController ()

@property (strong, nonatomic) UISwitch *callPushSwitch;
@property (strong, nonatomic) UISwitch *showCallInfoSwitch;

@property (nonatomic, strong) UISwitch *cameraSwitch;

@end

@implementation CallSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"setting.call", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISwitch *)callPushSwitch
{
    if (_callPushSwitch == nil) {
        _callPushSwitch = [self _setupSwitchWithAction:@selector(callPushChanged:)];
        
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        [_callPushSwitch setOn:options.isSendPushIfOffline animated:YES];
    }
    
    return _callPushSwitch;
}

- (UISwitch *)showCallInfoSwitch
{
    if (_showCallInfoSwitch == nil) {
        _showCallInfoSwitch = [self _setupSwitchWithAction:@selector(showCallInfoChanged:)];
        
        _showCallInfoSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"showCallInfo"] boolValue];
    }
    
    return _showCallInfoSwitch;
}

- (UISwitch *)cameraSwitch
{
    if (_cameraSwitch == nil) {
        _cameraSwitch = [self _setupSwitchWithAction:@selector(cameraSwitchValueChanged:)];
        
        _cameraSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
    }
    
    return _cameraSwitch;
}

#pragma mark - Subviews

- (UISwitch *)_setupSwitchWithAction:(SEL)aAction
{
    UISwitch *retSwitch = [[UISwitch alloc] init];
    [retSwitch addTarget:self action:aAction forControlEvents:UIControlEventValueChanged];
    
    CGRect frame = retSwitch.frame;
    frame.origin.x = self.view.frame.size.width - 10 - frame.size.width;
    frame.origin.y = 10;
    retSwitch.frame = frame;
    
    return retSwitch;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = 2;
    } else if (section == 1) {
        count = 1;
    } else if (section == 2) {
        count = 4;
    }
    
    return count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = @"";
    if (section == 0) {
        str = @"1v1设置";
    } else if (section == 1) {
        str = @"多人设置";
    } else if (section == 2) {
        str = @"通用设置";
    }
    
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.push", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.contentView addSubview:self.callPushSwitch];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.showInfo", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.contentView addSubview:self.showCallInfoSwitch];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"默认使用后置摄像头";
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.contentView addSubview:self.cameraSwitch];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.maxVKbps", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.minVKbps", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.autoResolution", nil);
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"setting.call.maxFramerate", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        if (indexPath.row == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"setting.call.maxVKbps", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = [NSString stringWithFormat:@"%ld", options.maxVideoKbps];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            
            __weak typeof(self) weakself = self;
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *textField = alertController.textFields.firstObject;
                [weakself _setCallOptions:@"maxVKbps" value:textField.text];
            }];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"setting.call.minVKbps", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = [NSString stringWithFormat:@"%d", options.minVideoKbps];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            
            __weak typeof(self) weakself = self;
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *textField = alertController.textFields.firstObject;
                [weakself _setCallOptions:@"minVKbps" value:textField.text];
            }];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        if (indexPath.row == 3) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"setting.call.maxFramerate", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = [NSString stringWithFormat:@"%d", options.maxVideoFrameRate];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            
            __weak typeof(self) weakself = self;
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *textField = alertController.textFields.firstObject;
                [weakself _setCallOptions:@"maxFramerate" value:textField.text];
            }];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - Action

- (void)_setCallOptions:(NSString *)param value:(NSString *)textValue
{
    int value = 0;
    if ([textValue length] > 0) {
        value = [textValue intValue];
    }
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if ([param isEqual:@"maxVKbps"]) {
        if ((value >= 150 && value <= 1000) || value == 0) {
            options.maxVideoKbps = value;
            [[SingleCallController sharedManager] saveCallOptions];
        } else {
            [self showHint:NSLocalizedString(@"setting.call.maxVKbpsTips", @"Video kbps should be 150-1000")];
        }
        return;
    }
    if ([param isEqual:@"minVKbps"]) {
        options.maxVideoFrameRate = value;
    }
    if ([param isEqual:@"maxFramerate"]) {
        options.minVideoKbps = value;
    }
    [[SingleCallController sharedManager] saveCallOptions];
}

- (void)showCallInfoChanged:(UISwitch *)control
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"showCallInfo"];
    [userDefaults synchronize];
}

- (void)callPushChanged:(UISwitch *)control
{
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.isSendPushIfOffline = control.on;
    [[SingleCallController sharedManager] saveCallOptions];
}

- (void)cameraSwitchValueChanged:(UISwitch *)control
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"em_IsUseBackCamera"];
    [userDefaults synchronize];
}

@end
