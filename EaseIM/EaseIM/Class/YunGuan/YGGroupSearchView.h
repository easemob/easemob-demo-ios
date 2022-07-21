//
//  YGGroupSearchView.h
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YGGroupSearchViewDelegate;
@interface YGGroupSearchView : UIView

@property (nonatomic, strong) UIButton *leftBackButton;
@property (nonatomic, strong) UILabel *searchTypeLabel;
@property (nonatomic, strong) UIImageView *vLineImageView;
@property (nonatomic, weak) id<YGGroupSearchViewDelegate> delegate;
@property (nonatomic, copy) void (^backActionBlock)(void);

@end

@protocol YGGroupSearchViewDelegate <NSObject>

@optional
- (void)showSearchGroupTypeTable;

- (void)searchViewShouldBeginEditing:(YGGroupSearchView *)searchView;

//点击搜索按钮
- (void)searchButtonClickedWithKeyword:(NSString *)keyword;

//
//- (void)searchBarCancelButtonAction:(YGGroupSearchView *)searchView;
//
//- (void)searchBarSearchButtonClicked:(NSString *)aString;
//
//- (void)searchTextDidChangeWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
