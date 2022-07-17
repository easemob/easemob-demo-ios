//
//  BQChatRecordImageVideoDemoViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/17.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordImageVideoDemoViewController.h"

@interface BQChatRecordImageVideoDemoViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation BQChatRecordImageVideoDemoViewController


- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    return [super initWithCoversationModel:conversation];
}


- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}


@end
