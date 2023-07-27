//
//  EMUrlPreviewMessageCell.h
//  EaseIM
//
//  Created by li xiaoming on 2023/7/18.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import <EaseIMKit/EaseIMKit.h>
#import <EaseIMKit/EaseMessageCell.h>

NS_ASSUME_NONNULL_BEGIN
@class EMUrlPreviewMessageCell;
@protocol EMUrlPreviewMessageCellDelegate <NSObject>

- (void)messageCellNeedReload:(EMUrlPreviewMessageCell *)cell;

@end

@interface EMUrlPreviewMessageCell : EaseMessageCell
@property (nonatomic, weak) id<EMUrlPreviewMessageCellDelegate> cellDelegate;
@end

NS_ASSUME_NONNULL_END
