//
//  EMHomeViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "BQTHomeViewController.h"
#import "BQPersonalGroupEnterViewController.h"
#import "BQTSettingViewController.h"

#define kTabbarItemTag_Conversation 0
#define kTabbarItemTag_Contact 1
#define kTabbarItemTag_Settings 2

@interface BQTHomeViewController ()<UITabBarDelegate, EaseIMKitManagerDelegate>

@property (nonatomic) BOOL isViewAppear;

@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;

@property (nonatomic, strong) BQPersonalGroupEnterViewController *conversationsController;
@property (nonatomic, strong) BQTSettingViewController *settingController;

@property (nonatomic, strong) UIView *addView;

@end

@implementation BQTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _setupSubviews];
    
    //监听消息接收，主要更新会话tabbaritem的badge
    [EaseIMKitManager.shared addDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.isViewAppear = YES;
    [self _loadConversationTabBarItemBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewAppear = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [EaseIMKitManager.shared removeDelegate:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-EMVIEWBOTTOMMARGIN);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.tabBar addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabBar.mas_top);
        make.left.equalTo(self.tabBar.mas_left);
        make.right.equalTo(self.tabBar.mas_right);
        make.height.equalTo(@1);
    }];
    
    [self _setupChildController];
}

- (UITabBarItem *)_setupTabBarItemWithTitle:(NSString *)aTitle
                                    imgName:(NSString *)aImgName
                            selectedImgName:(NSString *)aSelectedImgName
                                        tag:(NSInteger)aTag
{
    UITabBarItem *retItem = [[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:aImgName] selectedImage:[UIImage imageNamed:aSelectedImgName]];
    retItem.tag = aTag;
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor lightGrayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, UIColor.blueColor, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    return retItem;
}

- (void)_setupChildController
{
    self.conversationsController = [[BQPersonalGroupEnterViewController alloc]init];

    UITabBarItem *consItem = [self _setupTabBarItemWithTitle:NSLocalizedString(@"conversation", nil) imgName:@"icon-tab会话unselected" selectedImgName:@"icon-tab会话" tag:kTabbarItemTag_Conversation];
    self.conversationsController.tabBarItem = consItem;
    [self addChildViewController:self.conversationsController];
    
    self.settingController = [[BQTSettingViewController alloc]init];
    UITabBarItem *contItem = [self _setupTabBarItemWithTitle:@"设置" imgName:@"icon-tab通讯录unselected" selectedImgName:@"icon-tab通讯录" tag:kTabbarItemTag_Contact];
    self.settingController.tabBarItem = contItem;
    [self addChildViewController:self.settingController];
    

    
    self.viewControllers = @[self.conversationsController, self.settingController];
    
    [self.tabBar setItems:@[consItem, contItem]];
    
    self.tabBar.selectedItem = consItem;
    [self tabBar:self.tabBar didSelectItem:consItem];
    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    UIView *tmpView = nil;
    if (tag == kTabbarItemTag_Conversation)
        tmpView = self.conversationsController.view;
    if (tag == kTabbarItemTag_Contact)
        tmpView = self.settingController.view;

    if (self.addView == tmpView) {
        return;
    } else {
        [self.addView removeFromSuperview];
        self.addView = nil;
    }

    self.addView = tmpView;
    if (self.addView) {
        [self.view addSubview:self.addView];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.tabBar.mas_top);
        }];
    }
    
}

#pragma mark - EaseIMKitManagerDelegate

- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount
{
    
    NSInteger allUnread = EaseIMKitManager.shared.currentUnreadCount;
    NSInteger jhGroupUnread = EaseIMKitManager.shared.exclusivegroupUnReadCount;
    
    NSLog(@"%s allUnread:%ld\n jhGroupUnread:%ld\n",__func__,allUnread,jhGroupUnread);
    
}



- (void)enForceKickOffByServer {
    NSLog(@"%s",__func__);
    
}




#pragma mark - Private

- (void)_loadConversationTabBarItemBadge
{

}


@end
