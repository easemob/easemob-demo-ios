//
//  EMMsgURLPreviewBubbleView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/24.
//

#import "EMMsgURLPreviewBubbleView.h"
#import "EaseURLPreviewManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EaseEmojiHelper.h"

@interface EMMsgURLPreviewBubbleView ()
 {
     EaseChatViewModel *_viewModel;
 }

 @property (nonatomic, strong) UILabel *textLabel;
 @property (nonatomic, strong) UIView *urlPreviewLoadingView;
 @property (nonatomic, strong) UIImageView *urlPreviewLoadingImageView;
 @property (nonatomic, strong) UILabel *urlPreviewLoadingLabel;
 @property (nonatomic, strong) UIView *urlPreviewView;
 @property (nonatomic, strong) UILabel *titleLabel;
 @property (nonatomic, strong) UILabel *contentLabel;
 @property (nonatomic, strong) UIImageView *imageView;

 @end

 @implementation EMMsgURLPreviewBubbleView

 - (instancetype)initWithDirection:(EMMessageDirection)aDirection
                              type:(EMMessageType)aType
                         viewModel:(EaseChatViewModel *)viewModel
 {
     self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
     if (self) {
         _viewModel = viewModel;
         [self _setupSubviews];
     }

     return self;
 }

 #pragma mark - Subviews

 - (void)_setupSubviews
 {
     [self setupBubbleBackgroundImage];

     self.textLabel = [[UILabel alloc] init];
     self.textLabel.font = [UIFont systemFontOfSize:_viewModel.contentFontSize];
     self.textLabel.numberOfLines = 0;
     self.textLabel.textColor = _viewModel.contentFontColor;
     [self addSubview:self.textLabel];
     [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.left.equalTo(@10);
         make.right.bottom.equalTo(@-10);
     }];
     [self addSubview:self.textLabel];

     self.urlPreviewLoadingView.backgroundColor = UIColor.clearColor;
     [self addSubview:_urlPreviewLoadingView];

     _urlPreviewLoadingImageView = [[UIImageView alloc] init];
     _urlPreviewLoadingImageView.image = [UIImage imageNamed:@"url_preview_loading"];
     [_urlPreviewLoadingView addSubview:_urlPreviewLoadingImageView];

     _urlPreviewLoadingLabel = [[UILabel alloc] init];
     _urlPreviewLoadingLabel.font = [UIFont systemFontOfSize:11];
     _urlPreviewLoadingLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
     _urlPreviewLoadingLabel.text = @"解析中...";
     [_urlPreviewLoadingView addSubview:_urlPreviewLoadingLabel];

     [_urlPreviewLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self.textLabel.mas_bottom).offset(9);
         make.left.right.equalTo(self.textLabel);
         make.bottom.equalTo(@-9);
         make.height.equalTo(@16);
     }];

//     [_urlPreviewLoadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//         make.left.centerY.equalTo(_urlPreviewLoadingView);
//         make.size.equalTo(@16);
//     }];
//
//     [_urlPreviewLoadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//         make.centerY.equalTo(_urlPreviewLoadingView);
//         make.left.equalTo(_urlPreviewLoadingImageView.mas_right).offset(4);
//         make.right.equalTo(_urlPreviewLoadingView);
//     }];
 }

 #pragma mark - Setter

 - (void)setModel:(EaseMessageModel *)model
 {
     EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
     NSString *text = [EaseEmojiHelper convertEmoji:body.text];
     NSMutableAttributedString *attaStr = [[NSMutableAttributedString alloc] initWithString:text];

     NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
     NSArray *checkArr = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
     if (checkArr.count == 1) {
         NSTextCheckingResult *result = checkArr.firstObject;
         if (result.range.length > 0) {
             NSURL *url = result.URL;
             [attaStr setAttributes:@{
                 NSLinkAttributeName : url,
                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                 NSUnderlineColorAttributeName: self.tintColor
             } range:result.range];
         }
         EaseURLPreviewResult *previewResult = [EaseURLPreviewManager.shared resultWithURL:result.URL];
         if (previewResult && previewResult.state != EaseURLPreviewStateFaild) {
             [self updateLayoutWithURLPreview: previewResult];
         } else {
             [self updateLayoutWithoutURLPreview];
         }
     } else {
         [self updateLayoutWithoutURLPreview];
     }

     self.textLabel.attributedText = attaStr;
 }

 - (void)updateLayoutWithURLPreview:(EaseURLPreviewResult *)result
 {
     [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.top.left.equalTo(@10);
         make.right.equalTo(@-10);
     }];
     if (result.state == EaseURLPreviewStateSuccess) {
         _urlPreviewLoadingView.hidden = YES;
         self.urlPreviewView.hidden = NO;
         _titleLabel.text = result.title;
         _contentLabel.text = result.desc;
         [_imageView sd_setImageWithURL:[NSURL URLWithString:result.imageUrl] placeholderImage:[UIImage imageNamed:@"url_preview_placeholder"]];
         [_urlPreviewLoadingView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
         [_urlPreviewView mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.textLabel.mas_bottom).offset(9);
             if (self.direction == EMMessageDirectionSend) {
                 make.left.greaterThanOrEqualTo(@12);
                 make.right.equalTo(@-12);
             } else {
                 make.left.equalTo(@12);
                 make.right.lessThanOrEqualTo(@-12);
             }
             make.bottom.equalTo(@-9);
             make.height.equalTo(@100);
             make.width.equalTo(@217);
         }];
     } else {
         self.urlPreviewLoadingView.hidden = NO;
         _urlPreviewView.hidden = YES;
         [_urlPreviewView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
         [_urlPreviewLoadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.textLabel.mas_bottom).offset(9);
             make.left.right.equalTo(self.textLabel);
             make.bottom.equalTo(@-9);
             make.height.equalTo(@16);
         }];
     }
 }

 - (void)updateLayoutWithoutURLPreview
 {
     _urlPreviewView.hidden = YES;
     _urlPreviewLoadingView.hidden = YES;

     [_urlPreviewView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
     [_urlPreviewLoadingView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
     [_textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.top.left.equalTo(@10);
         make.right.bottom.equalTo(@-10);
     }];
 }

 - (UIView *)urlPreviewView
 {
     if (!_urlPreviewView) {
         _urlPreviewView = [[UIView alloc] init];
         _urlPreviewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.04];
         _urlPreviewView.layer.cornerRadius = 8;
         [self addSubview:_urlPreviewView];

         _titleLabel = [[UILabel alloc] init];
         _titleLabel.numberOfLines = 1;
         _titleLabel.textColor = UIColor.blackColor;
         _titleLabel.font = [UIFont systemFontOfSize:15];
         [_urlPreviewView addSubview:_titleLabel];

         _contentLabel = [[UILabel alloc] init];
         _contentLabel.numberOfLines = 4;
         _contentLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
         _contentLabel.font = [UIFont systemFontOfSize:12];
         [_urlPreviewView addSubview:_contentLabel];

         _imageView = [[UIImageView alloc] init];
         _imageView.backgroundColor = UIColor.clearColor;
         _imageView.image = [UIImage imageNamed:@"url_preview_placeholder"];
         _imageView.contentMode = UIViewContentModeScaleAspectFit;
         _imageView.layer.masksToBounds = YES;
         _imageView.layer.cornerRadius = 4;
         [_urlPreviewView addSubview:_imageView];

         [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.top.equalTo(@12);
             make.right.equalTo(@-12);
             make.height.equalTo(@20);
         }];

         [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(_titleLabel);
             make.top.equalTo(_titleLabel.mas_bottom).offset(4);
             make.right.equalTo(_imageView.mas_left).offset(-8);
         }];

         [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.equalTo(@52);
             make.right.equalTo(@-12);
             make.top.equalTo(@36);
         }];
     }
     return _urlPreviewView;
 }

 - (UIView *)urlPreviewLoadingView
 {
     if (!_urlPreviewLoadingView) {
         _urlPreviewLoadingView = [[UIView alloc] init];
         _urlPreviewLoadingView.backgroundColor = UIColor.clearColor;
         [self addSubview:_urlPreviewLoadingView];

         _urlPreviewLoadingImageView = [[UIImageView alloc] init];
         UIImage* image = [UIImage imageNamed:@"url_preview_loading"];
         _urlPreviewLoadingImageView.image = image;
         [_urlPreviewLoadingView addSubview:_urlPreviewLoadingImageView];

         _urlPreviewLoadingLabel = [[UILabel alloc] init];
         _urlPreviewLoadingLabel.font = [UIFont systemFontOfSize:11];
         _urlPreviewLoadingLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
         _urlPreviewLoadingLabel.text = @"解析中...";
         [_urlPreviewLoadingView addSubview:_urlPreviewLoadingLabel];

         [_urlPreviewLoadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.centerY.equalTo(_urlPreviewLoadingView);
             make.size.equalTo(@24);
         }];

         [_urlPreviewLoadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerY.equalTo(_urlPreviewLoadingView);
             make.left.equalTo(_urlPreviewLoadingImageView.mas_right).offset(4);
             make.right.equalTo(_urlPreviewLoadingView);
         }];
     }
     return _urlPreviewLoadingView;
 }

 @end
