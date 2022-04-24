//
//  EMDeveloperServiceViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMDeveloperServiceViewController.h"
#import "EMCustomAppkeyViewController.h"

@interface EMDeveloperServiceViewController ()<UIDocumentInteractionControllerDelegate>

@end

@implementation EMDeveloperServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    self.showRefreshHeader = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = NSLocalizedString(@"developerService", nil);
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    if (section == 1) {
        count = 3;
    } else if (section == 2) {
        count = 2;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identify = nil;
    BOOL isSwitch = NO;
    if (section == 0 || (section == 1 && row == 0) || (section == 2 && row == 1) || (section == 3)) {
        identify = @"UITableViewCellStyleValue1";
    } else {
        identify = @"UITableViewCellSwitch";
        isSwitch = YES;
    }
    UISwitch *switchControl = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitch) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    }

    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    if (section == 0) {
        cell.textLabel.text = NSLocalizedString(@"curSDKVer", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"V %@",[EMClient sharedClient].version];
        cell.accessoryType = UITableViewCellSelectionStyleNone;
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"customAppkey", nil);
            cell.detailTextLabel.text = [EMDemoOptions.sharedOptions.appkey isEqualToString:DEF_APPKEY] ? NSLocalizedString(@"default", nil) : EMDemoOptions.sharedOptions.appkey;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"fetchFromSerFirst", nil);
            [switchControl setOn:options.isPriorityGetMsgFromServer animated:YES];
        } else if (row == 2) {
            cell.textLabel.text = NSLocalizedString(@"uploadAttachment", nil);
            [switchControl setOn:options.isAutoTransferMessageAttachments animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"autoDownloadImageThuinail", nil);
            [switchControl setOn:options.isAutoDownloadThumbnail animated:YES];
        } else if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"sort", nil);
            cell.detailTextLabel.text = options.isSortMessageByServerTime ? NSLocalizedString(@"serverTime", nil) : NSLocalizedString(@"receiveOrder", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 3) {
        cell.textLabel.text = NSLocalizedString(@"exportLog", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && row == 0) {
        //自定义appkey
        EMCustomAppkeyViewController *customAppkeyController = [[EMCustomAppkeyViewController alloc]init];
        [self.navigationController pushViewController:customAppkeyController animated:YES];
    } else if (section == 2 && row == 1) {
        [self updateMessageSort];
    } else if (section == 3) {
        //日志
        [self saveLogToDocument];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0001;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 46;
    }
    
    return 16;
}

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        if (row == 1) {
            options.isPriorityGetMsgFromServer = aSwitch.isOn;
            [options archive];
        } else if (row == 2) {
            [EMClient sharedClient].options.isAutoTransferMessageAttachments = aSwitch.isOn;
            options.isAutoTransferMessageAttachments = aSwitch.isOn;
            [options archive];
        }
    } else if (section == 2) {
        [EMClient sharedClient].options.isAutoDownloadThumbnail = aSwitch.isOn;
        options.isAutoDownloadThumbnail = aSwitch.isOn;
        [options archive];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        UIView * view = [[UIView alloc] init];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.numberOfLines = 0;
        label.text = NSLocalizedString(@"uploadAttachmengtPrompt", nil);
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(view);
            make.left.equalTo(view).offset(20);
            make.right.equalTo(view).offset(-20);
        }];
        return view;
    }
    
    return nil;
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

//修改消息排序
- (void)updateMessageSort
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"sort", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"serverTime", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isSortMessageByServerTime = YES;
        [options archive];
        [EMClient sharedClient].options.sortMessageByServerTime = YES;
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"receiveOrder", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isSortMessageByServerTime = NO;
        [options archive];
        [EMClient sharedClient].options.sortMessageByServerTime = NO;
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//导出日志
- (void)saveLogToDocument {
    [[EMClient sharedClient] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        if (!aPath) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"fetchLogFail", nil)];
            return ;
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *toPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
        NSDate *datenow = [NSDate date];
        NSString *currentTimeString = [formatter stringFromDate:datenow];
        toPath = [toPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ log.gz", currentTimeString]];
        [fm copyItemAtPath:aPath toPath:toPath error:nil];
        
        [EMAlertController showSuccessAlert:NSLocalizedString(@"moveLog", nil)];
        
        NSURL *url = [NSURL fileURLWithPath:toPath];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        documentController.delegate = self;
        [documentController presentPreviewAnimated:YES];
        
    }];
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end
