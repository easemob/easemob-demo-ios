//
//  BQChatRecordContainerViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordContainerViewController.h"
#import "MISScrollPage.h"

#import "EMChatRecordViewController.h"
#import "BQChatRecordFileViewController.h"
#import "BQChatRecordImageVideoViewController.h"
//#import "BQChatRecordImageVideoDemoViewController.h"
#import "EMChatViewController.h"


#define kViewTopPadding  200.0f

@interface BQChatRecordContainerViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate,EMChatRecordViewControllerDelegate>
@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic,strong) EMChatRecordViewController *textRecordVC;
@property (nonatomic,strong) BQChatRecordFileViewController *fileRecordVC;

@property (nonatomic,strong) BQChatRecordImageVideoViewController *imageVideoRecordVC;
//@property (nonatomic,strong) BQChatRecordImageVideoDemoViewController *imageVideoRecordVC;


@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;

@property (nonatomic, strong) EMConversation *conversation;

@end

@implementation BQChatRecordContainerViewController
- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        [self setTitleAndContentVC];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewBgBlackColor;
    self.title = @"查找聊天记录";
    
    [self addPopBackLeftItemWithTarget:self action:@selector(backItemAction)];
    
    [self setTitleAndContentVC];
    [self placeAndLayoutSubviews];
    [self.pageController reloadData];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.segView];
    [self.view addSubview:self.contentView];
    
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(50.0));
    }];
    
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}


#pragma mark private method
- (BOOL)isGroupChat {
    BOOL _groupChat = self.conversation.type == EMConversationTypeGroupChat ? YES : NO;
    return _groupChat;
}


- (void)setTitleAndContentVC {
    
    if ([self isGroupChat]) {
        self.navTitleArray = [
            @[@"消息",@"文件",@"图片及视频"] mutableCopy];
        self.contentVCArray = [@[self.textRecordVC,self.fileRecordVC,self.imageVideoRecordVC] mutableCopy];
    }else {
        self.navTitleArray = [
            @[@"全部",@"图片及视频"] mutableCopy];
        self.contentVCArray = [@[self.textRecordVC,self.imageVideoRecordVC] mutableCopy];
    }
}

#pragma mark EMChatRecordViewControllerDelegate
- (void)didTapSearchMessage:(EMChatMessage *)message {
    EMChatViewController *chatController = [[EMChatViewController alloc]initWithConversationId:self.conversation.conversationId conversationType:self.conversation.type];
    [chatController scrollToAssignMessage:message];
    chatController.modalPresentationStyle = 0;
    [self.navigationController pushViewController:chatController animated:YES];

}

#pragma mark - scrool pager data source and delegate
- (NSUInteger)numberOfChildViewControllers {
    return self.navTitleArray.count;
}

- (NSArray*)titlesOfSegmentView {
    return self.navTitleArray;
}


- (NSArray*)childViewControllersOfContentView {
    return self.contentVCArray;
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


#pragma mark - setter or getter
- (MISScrollPageController*)pageController {
    if(!_pageController){
        MISScrollPageStyle* style = [[MISScrollPageStyle alloc] init];
//        style.showCover = YES;
//        style.coverBackgroundColor = COLOR_HEX(0xD8D8D8);
//        style.gradualChangeTitleColor = YES;
//        style.normalTitleColor = COLOR_HEX(0x999999);
//        style.selectedTitleColor = COLOR_HEX(0x000000);
//        style.scrollLineColor = COLOR_HEXA(0x000000, 0.5);

        style.coverBackgroundColor = COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = COLOR_HEX(0x7E7E7E);
        style.selectedTitleColor = COLOR_HEX(0xB9B9B9);
        style.scrollLineColor = COLOR_HEXA(0x000000, 0.5);
        style.segmentViewBackgroundColor = ViewBgBlackColor;
        
        style.scaleTitle = YES;
        style.autoAdjustTitlesWidth = YES;
        style.titleBigScale = 1.05;
        style.titleFont = Font(@"PingFang SC",14.0);
        style.showSegmentViewShadow = YES;
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];
    }
    return _pageController;
}


- (MISScrollPageSegmentView*)segView{
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
        
    }
    return _segView;
}


- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, KScreenWidth, KScreenHeight-kNavBarAndStatusBarHeight - 50.0)];
        _contentView.backgroundColor = UIColor.yellowColor;
    }
    return _contentView;
}


- (NSMutableArray *)navTitleArray {
    if (_navTitleArray == nil) {
        _navTitleArray = NSMutableArray.new;
    }
    return _navTitleArray;
}

- (NSMutableArray *)contentVCArray {
    if (_contentVCArray == nil) {
        _contentVCArray = NSMutableArray.new;
    }
    return _contentVCArray;
}

- (EMChatRecordViewController *)textRecordVC {
    if (_textRecordVC == nil) {
        _textRecordVC = [[EMChatRecordViewController alloc] initWithCoversationModel:self.conversation];
        _textRecordVC.delegate = self;
    }
    return _textRecordVC;
}


- (BQChatRecordFileViewController *)fileRecordVC {
    if (_fileRecordVC == nil) {
        _fileRecordVC = [[BQChatRecordFileViewController alloc] initWithCoversationModel:self.conversation];
    }
    return _fileRecordVC;
}

- (BQChatRecordImageVideoViewController *)imageVideoRecordVC {
    if (_imageVideoRecordVC == nil) {
        _imageVideoRecordVC = [[BQChatRecordImageVideoViewController alloc] initWithCoversationModel:self.conversation];
    }
    return _imageVideoRecordVC;
}

//- (BQChatRecordImageVideoDemoViewController *)imageVideoRecordVC {
//    if (_imageVideoRecordVC == nil) {
//        _imageVideoRecordVC = [[BQChatRecordImageVideoDemoViewController alloc] initWithCoversationModel:self.conversation];
//    }
//    return _imageVideoRecordVC;
//}


@end

#undef kViewTopPadding

