//
//  YGGroupSearchView.m
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupSearchView.h"

#define kTextFieldHeight 32.0f

@interface YGGroupSearchView()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *triangleButton;
@property (nonatomic, strong) UIImageView *triangleImageView;
@property (nonatomic, strong) UIButton *searchButton;


@end

@implementation YGGroupSearchView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews {

    self.backgroundColor = ViewBgWhiteColor;

    [self addSubview:self.leftBackButton];
    [self addSubview:self.contentView];
    [self addSubview:self.searchButton];
    

    [self.leftBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(16.0);
        make.size.equalTo(@(28.0));
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.leftBackButton.mas_right);
        make.right.equalTo(self.searchButton.mas_left).offset(-8.0);
        make.height.equalTo(@(32.0));
    }];

    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-16.0);
        make.width.equalTo(@(40.0));
        make.height.equalTo(@(16.0));
    }];
   
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-65);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchViewShouldBeginEditing:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
//        [self.delegate searchBarSearchButtonClicked:textField.text];
//    }
    
    [self searchButtonClicked];
    
    return YES;
}

#pragma mark - Action

- (void)textFieldTextDidChange
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
//        [self.delegate searchTextDidChangeWithString:_textField.text];
//    }
}


- (void)leftBackButtonClicked {
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)triangleButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showSearchGroupTypeTable)]) {
        [self.delegate showSearchGroupTypeTable];
    }
}

- (void)searchButtonClicked {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchButtonClickedWithKeyword:)]) {
        [self.delegate searchButtonClickedWithKeyword:self.textField.text];
    }
}

#pragma mark getter and setter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 32.0 * 0.5;
        _contentView.backgroundColor = UIColor.whiteColor;
        
        [_contentView addSubview:self.triangleButton];
        [_contentView addSubview:self.vLineImageView];
        [_contentView addSubview:self.textField];

        [self.triangleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_contentView);
            make.left.equalTo(_contentView).offset(8.0);
            make.width.equalTo(@(100.0));
        }];
        
        [self.vLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_contentView);
            make.left.equalTo(self.triangleButton.mas_right).offset(8.0);
            make.width.equalTo(@(BQ_ONE_PX));
            make.height.equalTo(@(16.0));
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_contentView);
            make.left.equalTo(self.vLineImageView.mas_right).offset(8.0);
            make.right.equalTo(_contentView).offset(-8.0);
            make.height.equalTo(@(32.0));
        }];
        
    }
    return _contentView;
}

- (UIButton *)leftBackButton {
    if (_leftBackButton == nil) {
        _leftBackButton = [[UIButton alloc] init];
        [_leftBackButton setImage:ImageWithName(@"yg_backleft") forState:UIControlStateNormal];
        
        [_leftBackButton addTarget:self action:@selector(leftBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBackButton;
}

- (UIButton *)triangleButton {
    if (_triangleButton == nil) {
        _triangleButton = [[UIButton alloc] init];
        [_triangleButton addTarget:self action:@selector(triangleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_triangleButton addSubview:self.searchTypeLabel];
        [_triangleButton addSubview:self.triangleImageView];

        [self.searchTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_triangleButton);
            make.left.equalTo(_triangleButton);
            make.width.equalTo(@(100.0));
        }];
        
        [self.triangleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_triangleButton);
            make.left.equalTo(self.searchTypeLabel.mas_right).offset(5.0);
            make.size.equalTo(@(16.0));
            make.right.equalTo(_triangleButton);
        }];

    }
    return _triangleButton;
}



- (UILabel *)searchTypeLabel {
    if (_searchTypeLabel == nil) {
        _searchTypeLabel = [[UILabel alloc] init];
        _searchTypeLabel.font = Font(@"PingFang SC", 14.0);
        _searchTypeLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _searchTypeLabel.textAlignment = NSTextAlignmentCenter;
        _searchTypeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _searchTypeLabel.text = @"群名称";
    }
    return _searchTypeLabel;
}

- (UIImageView *)triangleImageView {
    if (_triangleImageView == nil) {
        _triangleImageView = UIImageView.new;
        [_triangleImageView setImage:ImageWithName(@"yg_drop_down")];
    }
    return _triangleImageView;
}

- (UIImageView *)vLineImageView {
    if (_vLineImageView == nil) {
        _vLineImageView = UIImageView.new;
        _vLineImageView.backgroundColor = UIColor.grayColor;
        
    }
    return _vLineImageView;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        
        _textField.font = [UIFont systemFontOfSize:14.0];
        _textField.placeholder = NSLocalizedString(@"search", nil);
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.layer.cornerRadius = kTextFieldHeight * 0.5;
                
        _textField.backgroundColor = [UIColor whiteColor];
        [_textField setTextColor:UIColor.blackColor];
    }
    return _textField;
}


- (UIButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[UIButton alloc] init];
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor colorWithHexString:@"#4798CB"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}


@end

#undef kTextFieldHeight

