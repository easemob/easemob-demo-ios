//
//  EMUrlPreviewMessageCell.m
//  EaseIM
//
//  Created by li xiaoming on 2023/7/18.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import "EMUrlPreviewMessageCell.h"
#import "EMMsgURLPreviewBubbleView.h"

@interface EMUrlPreviewMessageCell() <EMMsgURLPreviewBubbleViewDelegate>

@end

@implementation EMUrlPreviewMessageCell

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    identifier = [NSString stringWithFormat:@"%@URLPreview", identifier];
    
    return identifier;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (EMMessageBubbleView *)_getBubbleViewWithType:(EMMessageType)aType
{
    EMMsgURLPreviewBubbleView* urlPreviewBubbleView = [[EMMsgURLPreviewBubbleView alloc] initWithDirection:self.direction type:aType viewModel:[[EaseChatViewModel alloc] init]];
    if (urlPreviewBubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [urlPreviewBubbleView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressAction:)];
        [urlPreviewBubbleView addGestureRecognizer:longPress];
    }
    urlPreviewBubbleView.delegate = self;
    return urlPreviewBubbleView;
}

- (void)URLPreviewBubbleViewNeedLayout:(EMMsgURLPreviewBubbleView *)view
{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(messageCellNeedReload:)]) {
        [self.cellDelegate messageCellNeedReload:self];
    }
}

@end
