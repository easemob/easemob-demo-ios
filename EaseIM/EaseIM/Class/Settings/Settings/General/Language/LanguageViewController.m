//
//  LanguageViewController.m
//  EaseIM
//
//  Created by lixiaoming on 2021/11/10.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "LanguageViewController.h"
#import "EMDemoOptions.h"
#import "LanguageCell.h"

@interface LanguageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray<EMLanguage *> * allLanguages;
@property (nonatomic,strong) NSString* selectLanguage;
@property (nonatomic,strong) UITableView* tableView;
@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupSubviews];
    [self _loadLanguages];
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(completeAction)];
    self.title = NSLocalizedString(@"languageSetting", nil);
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)completeAction
{
    [EMDemoOptions sharedOptions].language = self.selectLanguage;
    [[EMDemoOptions sharedOptions] archive];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableView*)tableView
{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)_loadLanguages
{
    // 加载目标语言
    self.selectLanguage = [EMDemoOptions sharedOptions].language;
    if(self.selectLanguage.length == 0) {
        NSString* localeID = [NSLocale currentLocale].localeIdentifier;
        NSDictionary* components = [NSLocale componentsFromLocaleIdentifier:localeID];
        self.selectLanguage = components[NSLocaleLanguageCode];
    }
    self.allLanguages = [self defaultLanguages];
    [self.tableView reloadData];
//    __weak typeof(self) weakself = self;
//    [[EMTranslationManager sharedManager] fetchSupportedLanguages:^(NSArray<EMLanguage *> * _Nullable languages, EMError * _Nullable error) {
//        if(!error) {
//            weakself.allLanguages = languages;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakself.tableView reloadData];
//            });
//        }
//    }];
}

- (NSArray<EMLanguage*>*)defaultLanguages
{
    return @[
        [EMLanguage initializeWithLanguageCode:@"zh-Hans" nativeName:@"中文 (简体)"],
        [EMLanguage initializeWithLanguageCode:@"zh-Hant" nativeName:@"繁體中文 (繁體)"],
        [EMLanguage initializeWithLanguageCode:@"en" nativeName:@"English"],
        [EMLanguage initializeWithLanguageCode:@"id" nativeName:@"Indonesia"],
        [EMLanguage initializeWithLanguageCode:@"ko" nativeName:@"한국어"],
        [EMLanguage initializeWithLanguageCode:@"it" nativeName:@"Italiano"],
        [EMLanguage initializeWithLanguageCode:@"pt" nativeName:@"Português (Brasil)"],
        [EMLanguage initializeWithLanguageCode:@"ja" nativeName:@"日本語"],
        [EMLanguage initializeWithLanguageCode:@"fr" nativeName:@"Français"],
        [EMLanguage initializeWithLanguageCode:@"de" nativeName:@"Deutsch"]
    ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.allLanguages.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LanguageCell *cell = (LanguageCell*)[tableView dequeueReusableCellWithIdentifier:@"LanguageCell"];
    
    
    // Configure the cell...
    if(!cell) {
        cell = [[LanguageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LanguageCell"];
    }
    EMLanguage* language = [self.allLanguages objectAtIndex:indexPath.row];
    cell.textLabel.text = language.languageNativeName;
    cell.language = language.languageCode;
    cell.checkView.hidden = ![cell.language isEqualToString:self.selectLanguage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMLanguage* language = [self.allLanguages objectAtIndex:indexPath.row];
    NSString* selectedLanguage = language.languageCode;
    if(![selectedLanguage isEqualToString:self.selectLanguage]) {
        self.selectLanguage = selectedLanguage;
        [self.tableView reloadData];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
