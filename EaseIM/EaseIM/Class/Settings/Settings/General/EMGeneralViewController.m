//
//  EMGeneralViewController.m
//  EaseIM
//
//  Updated by zhangchong on 2020/6/10.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMGeneralViewController.h"
#import "SPDateTimePickerView.h"

#import "EMDemoOptions.h"
#import "EMServiceCheckViewController.h"
#import "EMGeneralTitleSwitchCell.h"

static NSString *generalCellIndetifier = @"GeneralCellIndetifier";

@interface EMGeneralViewController ()<SPDateTimePickerViewDelegate>

@property (nonatomic, assign) BOOL silentModeEnabled;

@property (nonatomic, strong) UITableViewCell *silentTimeCell;

@end

@implementation EMGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"通用";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.silentModeEnabled = [EMClient sharedClient].pushManager.pushOptions.isNoDisturbEnable;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = 0;
    switch (section) {
        case 0:
        {
            if(self.silentModeEnabled == NO){
                count = 1;
            } else {
                count = 2;
            }
        }
            break;
        case 1:
            count = 1;
            break;
        case 2:
            count = 2;
            break;
        default:
            break;
    }
        
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
        
    EMGeneralTitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:generalCellIndetifier];
    if (cell == nil) {
        cell = [[EMGeneralTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:generalCellIndetifier];
    }
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    
    if (section == 0) {
        if (row == 0) {
            cell.nameLabel.text = @"消息免打扰";
            [cell.aSwitch setOn:(self.silentModeEnabled) animated:NO];
            
            EM_WS
            cell.switchActionBlock = ^(BOOL isOn) {
                [weakSelf disturbValueChanged];
            };
            
        } else if (row == 1) {

            NSInteger startHour = [EMClient sharedClient].pushManager.pushOptions.noDisturbingStartH;
            NSInteger endHour = [EMClient sharedClient].pushManager.pushOptions.noDisturbingEndH;
                        
            if (startHour == 0  && (endHour == 0 ||endHour == 24)) {
                self.silentTimeCell.detailTextLabel.text = @"全天";
            } else {
                self.silentTimeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@:00 - %@:00", @([EMClient sharedClient].pushManager.pushOptions.noDisturbingStartH), @([EMClient sharedClient].pushManager.pushOptions.noDisturbingEndH)];
            }
            
            return self.silentTimeCell;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.nameLabel.text = @"显示输入状态";
            [cell.aSwitch setOn:options.isChatTyping animated:NO];
            EM_WS
            cell.switchActionBlock = ^(BOOL isOn) {
                options.isChatTyping = isOn;
                [[EMDemoOptions sharedOptions] archive];
                [weakSelf.tableView reloadData];
            };
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.nameLabel.text = @"自动接受群组邀请";
            [cell.aSwitch setOn:options.isAutoAcceptGroupInvitation animated:NO];
            EM_WS
            cell.switchActionBlock = ^(BOOL isOn) {
                [EMClient sharedClient].options.isAutoAcceptGroupInvitation = isOn;
                options.isAutoAcceptGroupInvitation = isOn;
                [options archive];
                [weakSelf.tableView reloadData];

            };
            
        } else if (row == 1) {
            cell.nameLabel.text = @"退出群组时删除会话";
            [cell.aSwitch setOn:[EMClient sharedClient].options.isDeleteMessagesWhenExitGroup animated:NO];
            EM_WS
            cell.switchActionBlock = ^(BOOL isOn) {
                [[EMClient sharedClient].options setIsDeleteMessagesWhenExitGroup:isOn];
                [weakSelf.tableView reloadData];
            };
           
        }
    }

    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    if (section == 2) {
        return 46;
    }
    return 16;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"     群组设置";
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            [self changeDisturbDateAction];
        }
    }
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

#pragma mark - Action
- (void)disturbValueChanged
{
   
    if (self.silentModeEnabled) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            EMError *error = [[EMClient sharedClient].pushManager enableOfflinePush];
            if (error == nil) {
                self.silentModeEnabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                [EMAlertController showErrorAlert:error.errorDescription];
            }
        });
        
    }else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            int noDisturbingStartH = 0;
            int noDisturbingEndH = 24;
            
            EMError *error = [[EMClient sharedClient].pushManager disableOfflinePushStart:noDisturbingStartH end:noDisturbingEndH];
            if (error == nil) {
                self.silentModeEnabled = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }else {
                [EMAlertController showErrorAlert:error.errorDescription];
            }
        });
    }
}


- (void)changeDisturbDateAction
{
    SPDateTimePickerView *pickerView = [[SPDateTimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  self.view.frame.size.height)];
    pickerView.pickerViewMode = SPDatePickerModeTime;
    pickerView.delegate = self;
    pickerView.title = @"设置时间段";
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

#pragma mark - SPDateTimePickerViewDelegate
- (void)didClickFinishDateTimePickerView:(NSString *)date {
    NSLog(@"%@",date);
    NSRange range = [date rangeOfString:@"-"];
    NSString *start = [date substringToIndex:range.location];
    NSString *end = [date substringFromIndex:range.location + 1];
    if ([start isEqualToString:end]) {
        [self showHint:@"起止时间不能相同"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int noDisturbingStartH = [start intValue];;
        int noDisturbingEndH = [end intValue];
        EMError *error = [[EMClient sharedClient].pushManager disableOfflinePushStart:noDisturbingStartH end:noDisturbingEndH];
        if (!error) {
            [self hideHud];
            self.silentModeEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            [EMAlertController showErrorAlert:error.errorDescription];
        }
    });
    
}


#pragma mark getter and setter
- (UITableViewCell *)silentTimeCell {
    if (_silentTimeCell == nil) {
        _silentTimeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"silentTimeCell"];
        _silentTimeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _silentTimeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _silentTimeCell.textLabel.text = @"免打扰时间";
        _silentTimeCell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _silentTimeCell.textLabel.font = [UIFont systemFontOfSize:14.0];
        _silentTimeCell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);

    }
    return _silentTimeCell;
}


@end
