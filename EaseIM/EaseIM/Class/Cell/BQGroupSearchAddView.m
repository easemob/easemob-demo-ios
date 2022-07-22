//
//  BQGroupSearchAddedView.m
//  EaseIM
//
//  Created by liu001 on 2022/7/10.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupSearchAddView.h"
#import "UserInfoStore.h"


#define kMaxNameLabelWidth 70.0
#define kCollectionItemHeight 24.0

@interface BQGroupAddItemCell : UICollectionViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) void (^deleteMemberBlock)(NSString *userId);
@property (nonatomic, strong) NSString *userId;

+ (CGSize)sizeForItemUserId:(NSString *)userId;

@end

@implementation BQGroupAddItemCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.deleteButton];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel).offset(-12.0);
        make.right.equalTo(self.deleteButton).offset(12.0);
        make.height.equalTo(@(24.0));
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12.0);
        make.width.lessThanOrEqualTo(@(kMaxNameLabelWidth));
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.nameLabel.mas_right);
        make.size.equalTo(@(14.0));
    }];
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)updateWithObj:(id)obj {
    if (obj == nil) {
        return;
    }
    
    NSString *aUid = (NSString *)obj;
    self.userId = aUid;
    
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:self.userId];
    if(userInfo) {
        self.nameLabel.text = userInfo.nickName.length > 0 ? userInfo.nickName: userInfo.userId;
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
        self.nameLabel.text = self.userId;
    }
}

- (void)deleteButtonAction {
    if (self.deleteMemberBlock) {
        self.deleteMemberBlock(self.userId);
    }
}

+ (CGSize)sizeForItemUserId:(NSString *)userId {
//    CGFloat contentWidth = [userId sizeWithFont:[BQGroupAddItemCell labelFont] constrainedToSize:CGSizeMake(kMaxNameLabelWidth, 24.0)].width;

    return CGSizeMake(kMaxNameLabelWidth, 24.0);
}

#pragma mark getter and setter
- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 24.0 * 0.5;
        _bgView.clipsToBounds = YES;
        _bgView.layer.masksToBounds = YES;
#if kJiHuApp
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#252525"];
#else
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
#endif
        
        
    }
    return _bgView;
}


- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] init];
        _deleteButton.contentMode = UIViewContentModeScaleAspectFit;

        [_deleteButton setImage:ImageWithName(@"jh_invite_delete") forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
    
}

+ (UIFont *)labelFont {
    return NFont(12.0);
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [BQGroupAddItemCell labelFont];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
#if kJiHuApp
        _nameLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
#else
        _nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
#endif
        
    }
    return _nameLabel;
}


@end




@interface BQGroupSearchAddView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@end



@implementation BQGroupSearchAddView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
#if kJiHuApp
    self.backgroundColor = ViewCellBgBlackColor;
#else
    self.backgroundColor = ViewCellBgWhiteColor;
#endif

    [self addSubview:self.titleLabel];
    [self addSubview:self.collectionView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16.0);
        make.left.equalTo(self).offset(kBQPadding * 1.6);
        make.width.equalTo(@(150.0));
        make.height.equalTo(@(20.0));
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10.0);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray {
    self.dataArray = memberArray;
    [self.collectionView reloadData];
    [self updateViewHeight];
}


#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *userId = self.dataArray[indexPath.row];
    return [BQGroupAddItemCell sizeForItemUserId:userId];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BQGroupAddItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BQGroupAddItemCell reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    BQ_WS
    cell.deleteMemberBlock = ^(NSString *userId) {
        [weakSelf updateUIWithDeleteUserId:userId];
    };
    
    [cell updateWithObj:obj];
    return cell;
}


- (void)updateUIWithDeleteUserId:(NSString *)userId {
    if ([self.dataArray containsObject:userId]) {
        [self.dataArray removeObject:userId];
        [self.collectionView reloadData];
        [self updateViewHeight];
        if (self.deleteMemberBlock) {
            self.deleteMemberBlock(userId);
        }
    }
}


- (void)updateViewHeight {
    
    CGFloat height = 0;
    
    if (self.dataArray.count > 0) {
        height += 16.0 + 20.0 + 10.0;
       
        CGFloat aWidth = 0;
        CGFloat rowHeight = 1;
        CGFloat aMaxWidth = KScreenWidth - 16.0 *2 - 10.0 * 5;
        
        for (int i = 0; i< self.dataArray.count; ++i) {
            NSString *userId = self.dataArray[i];
            CGFloat iWidth = [BQGroupAddItemCell sizeForItemUserId:userId].width;
            aWidth += iWidth;
            if (aWidth >= aMaxWidth) {
                rowHeight += 1;
                aWidth = iWidth;
            }
        }

        height += rowHeight * 24.0 + (rowHeight -1) *10.0;
        
    }else {
        height = 0;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightForGroupSearchAddView:)]) {
        [self.delegate heightForGroupSearchAddView:height];
    }
}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[BQGroupAddItemCell class] forCellWithReuseIdentifier:[BQGroupAddItemCell reuseIdentifier]];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0);
    
    return flowLayout;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NFont(14.0);
        _titleLabel.textColor = [UIColor colorWithHexString:@"#7E7E7E"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.text = @"已选用户";
    }
    return _titleLabel;
}


@end

#undef kMaxNameLabelWidth
#undef kCollectionItemHeight
