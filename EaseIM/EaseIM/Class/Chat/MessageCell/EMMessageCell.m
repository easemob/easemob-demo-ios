//
//  EMMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageCell.h"

#import "EMMessageStatusView.h"
#import "EMMsgPicMixTextBubbleView.h"

@interface EMMessageCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) EMMessageStatusView *statusView;

@end

@implementation EMMessageCell

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType

{
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:aDirection type:aType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        [self _setupViewsWithType:aType];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    if (aType == EMMessageTypePictMixText) {
        return [NSString stringWithFormat:@"%@PictMixText", identifier];
    }
    return identifier;
}

#pragma mark - Subviews

- (void)_setupViewsWithType:(EMMessageType)aType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageAvatarDidSelected:)];
    [_avatarView addGestureRecognizer:tap];
    _avatarView.layer.cornerRadius = 8;
    [self.contentView addSubview:_avatarView];
    if (self.direction == EMMessageDirectionSend) {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-2*componentSpacing);
            make.width.height.equalTo(@(avatarLonger));
        }];
    } else {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(2*componentSpacing);
            make.width.height.equalTo(@(avatarLonger));
        }];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        if (_model.message.chatType != EMChatTypeChat) {
            [self.contentView addSubview:_nameLabel];
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.avatarView);
                make.left.equalTo(self.avatarView.mas_right).offset(8);
                make.right.equalTo(self.contentView).offset(-componentSpacing);
            }];
        }
    }
    
    self.bubbleView = [self _getBubbleViewWithType];
    self.bubbleView.userInteractionEnabled = YES;
    self.bubbleView.clipsToBounds = YES;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == EMMessageDirectionReceive) {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.avatarView.mas_right).offset(componentSpacing);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }];
    } else {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.avatarView.mas_left).offset(-componentSpacing);
        }];
    }

    _statusView = [[EMMessageStatusView alloc] init];
    [self.contentView addSubview:_statusView];
    if (self.direction == EMMessageDirectionSend) {
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView.mas_centerY);
            make.right.equalTo(self.bubbleView.mas_left).offset(-5);
            make.height.equalTo(@(componentSpacing * 2));
        }];
    } else {
        _statusView.backgroundColor = [UIColor redColor];
        _statusView.clipsToBounds = YES;
        _statusView.layer.cornerRadius = 4;
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView);
            make.left.equalTo(self.bubbleView.mas_right).offset(5);
            make.width.height.equalTo(@8);
        }];
    }
}

- (EMMsgPicMixTextBubbleView *)_getBubbleViewWithType
{
    self.bubbleView = [[EMMsgPicMixTextBubbleView alloc]init];
    if (self.direction == EMMessageDirectionSend) {
        self.bubbleView.image = [[UIImage imageNamed:@"msg_bg_send"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    } else {
        self.bubbleView.image = [[UIImage imageNamed:@"msg_bg_recv"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    if (self.bubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [self.bubbleView addGestureRecognizer:tap];
    }
    
    return self.bubbleView;
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    _model = model;
    [self.bubbleView setModel:_model];
    if (model.direction == EMMessageDirectionSend) {
        [self.statusView setSenderStatus:model.message.status isReadAcked:model.message.isReadAcked];
    } else {
        self.nameLabel.text = model.message.from;
        if (model.type == EMMessageTypePictMixText) {
            if ([((EMTextMessageBody *)model.message.body).text isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL])
                self.statusView.hidden = model.message.isReadAcked;
            else self.statusView.hidden = YES;
        }
    }
    _avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
}

#pragma mark - Action

//头像点击
- (void)messageAvatarDidSelected:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageAvatarDidSelected:)]) {
            [self.delegate messageAvatarDidSelected:_model];
        }
    }
}
//气泡点击
- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelected:)]) {
            [self.delegate messageCellDidSelected:self];
        }
    }
}

@end
