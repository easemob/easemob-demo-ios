//
//  EMChatRecordViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSearchViewController.h"
#import "EMSearchContainerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatRecordViewControllerDelegate <NSObject>
@optional
- (void)didTapSearchMessage:(EMChatMessage *)message;

@end

@interface EMChatRecordViewController : EMSearchContainerViewController
@property (nonatomic, assign) id<EMChatRecordViewControllerDelegate> delegate;

- (instancetype)initWithCoversationModel:(EMConversation *)conversation;


@end

NS_ASSUME_NONNULL_END
