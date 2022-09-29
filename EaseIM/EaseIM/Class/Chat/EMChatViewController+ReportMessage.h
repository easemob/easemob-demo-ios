//
//  EMChatViewController+ReportMessage.h
//  EaseIM
//
//  Created by li xiaoming on 2022/8/12.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import "EMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController (ReportMessage) <UITextFieldDelegate>
- (void)reportMenuItemAction:(EMChatMessage *)message;
@end

NS_ASSUME_NONNULL_END
