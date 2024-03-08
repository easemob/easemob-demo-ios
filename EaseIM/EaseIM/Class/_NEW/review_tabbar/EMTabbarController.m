//
//  EMTabbarController.m
//  EaseIM
//
//  Created by 杨剑 on 2024/3/8.
//  Copyright © 2024 杨剑. All rights reserved.
//

#import "EMTabbarController.h"

#import "EMMineViewController.h"
#import "EMRemindManager.h"
#import "EMConversationsViewController.h"
#import "EMContactsViewController.h"
#import "EaseIMHelper.h"

@interface EMTabbarController ()
< EMChatManagerDelegate, EaseIMKitManagerDelegate>

@property (nonatomic) BOOL isViewAppear;

@property (nonatomic, strong) EMConversationsViewController *conversationVC;
@property (nonatomic, strong) EMContactsViewController *contactVC;
@property (nonatomic, strong) EMMineViewController *mineVC;
//@property (nonatomic, strong) EMMineViewController *mineController;
//@property (nonatomic, strong) UIView *addView;

@end

@implementation EMTabbarController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    self.isViewAppear = YES;
    [self _loadConversationTabBarItemBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppear = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSubVC];
    [self configData];
    [self configObservers];
    
    
}

- (void)configSubVC{
    __weak typeof(self)weakSelf = self;
    
    NSMutableArray <UIViewController *>*childViewControlers = NSMutableArray.new;
    [self createControllerWithVCClass:EMConversationsViewController.class title:@"会话" imageName:@"icon-tab会话unselected" selectedImageName:@"icon-tab会话" completion:^(UIViewController *vc, UINavigationController *nc) {
        weakSelf.conversationVC = (EMConversationsViewController *)vc;
        [childViewControlers addObject:nc];
    }];
    [self createControllerWithVCClass:EMContactsViewController.class title:@"通讯录" imageName:@"icon-tab通讯录unselected" selectedImageName:@"icon-tab通讯录" completion:^(UIViewController *vc, UINavigationController *nc) {
        weakSelf.contactVC = (EMContactsViewController *)vc;
        [childViewControlers addObject:nc];
    }];
    [self createControllerWithVCClass:EMMineViewController.class title:@"我" imageName:@"icon-tab我unselected" selectedImageName:@"icon-tab我" completion:^(UIViewController *vc, UINavigationController *nc) {
        weakSelf.mineVC = (EMMineViewController *)vc;
        [childViewControlers addObject:nc];
    }];
    self.viewControllers = childViewControlers;

}

- (void)configData{
    
}

- (void)configObservers{
    //监听消息接收，主要更新会话tabbaritem的badge
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [EaseIMKitManager.shared addDelegate:self];
}



//配置视图控制器
- (void)createControllerWithVCClass:(Class)class title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName completion:(void(^)(UIViewController *vc,UINavigationController *nc))completion{
    UIViewController *vc = class.new;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    vc.tabBarItem.selectedImage = [UIImage imageNamed:selectedImageName];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = UINavigationBarAppearance.new;
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.backgroundColor = UIColor.whiteColor;
        [navBarAppearance setTitleTextAttributes: @{
            NSForegroundColorAttributeName:UIColor.blackColor,
            NSFontAttributeName: [UIFont systemFontOfSize:18],
        }];
        navBarAppearance.shadowColor = UIColor.clearColor;
        nc.navigationBar.standardAppearance = navBarAppearance;
        nc.navigationBar.scrollEdgeAppearance = navBarAppearance;
    }else{
        //设置导航条背景色
        nc.navigationBar.barTintColor = UIColor.whiteColor;
        nc.navigationBar.shadowImage = UIImage.new;
        [nc.navigationBar setTitleTextAttributes:@{
            NSForegroundColorAttributeName: UIColor.blackColor,
            NSFontAttributeName:[UIFont systemFontOfSize:18],
        }];
    }
    completion(vc,nc);
}









#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMChatMessage *msg in aMessages) {
        [EMRemindManager remindMessage:msg];
        if (msg.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
            //通话邀请
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:msg.conversationId type:EMConversationTypeGroupChat createIfNotExist:YES];
            if ([((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
                [conversation deleteMessageWithId:msg.messageId error:nil];
                continue;
            }
        }
        
        [EMRemindManager remindMessage:msg];
    }
    
    if (self.isViewAppear) {
        [self _loadConversationTabBarItemBadge];
    }
    
}

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    [self _loadConversationTabBarItemBadge];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self _loadConversationTabBarItemBadge];
}

- (void)onConversationRead:(NSString *)from to:(NSString *)to
{
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - EaseIMKitManagerDelegate

- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.conversationVC.tabBarItem.badgeValue = unreadCount > 0 ? @(unreadCount).stringValue : nil;
    });
    [EMRemindManager updateApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - Private

- (void)_loadConversationTabBarItemBadge
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if ([[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversation.conversationId]) {//单聊免打扰会话
            continue;
        }
        if ([[[EMClient sharedClient].pushManager noPushGroups] containsObject:conversation.conversationId]) {//群聊免打扰会话
            continue;
        }
        unreadCount += conversation.unreadMessagesCount;
    }
    self.conversationVC.tabBarItem.badgeValue = unreadCount > 0 ? @(unreadCount).stringValue : nil;
    [EMRemindManager updateApplicationIconBadgeNumber:unreadCount];
}







@end
