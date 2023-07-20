//
//  EMMsgURLPreviewBubbleView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/24.
//

#import <EaseIMKit/EMMessageBubbleView.h>

NS_ASSUME_NONNULL_BEGIN

@class EMMsgURLPreviewBubbleView;
@protocol EMMsgURLPreviewBubbleViewDelegate <NSObject>

- (void)URLPreviewBubbleViewNeedLayout:(EMMsgURLPreviewBubbleView *)view;

@end


@interface EMMsgURLPreviewBubbleView : EMMessageBubbleView
@end

NS_ASSUME_NONNULL_END
