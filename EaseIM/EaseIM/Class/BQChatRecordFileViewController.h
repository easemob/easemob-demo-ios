//
//  BQChatRecordFileViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol BQChatRecordFileViewControllerDelegate <NSObject>
@optional
- (void)didTapSearchFileMessage:(EMChatMessage *)message;

@end

@interface BQChatRecordFileViewController : UIViewController
@property (nonatomic) BOOL isSearching;
@property (nonatomic, assign) id<BQChatRecordFileViewControllerDelegate> delegate;

- (instancetype)initWithCoversationModel:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
