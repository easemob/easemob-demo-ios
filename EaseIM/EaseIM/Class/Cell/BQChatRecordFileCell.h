//
//  BQChatRecordFileCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BQChatRecordFileModel;

NS_ASSUME_NONNULL_BEGIN

@interface BQChatRecordFileCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *timestampLabel;

@property (nonatomic, strong) UIButton *accessoryButton;

@property (nonatomic, strong) BQChatRecordFileModel *model;


@end


NS_ASSUME_NONNULL_END
