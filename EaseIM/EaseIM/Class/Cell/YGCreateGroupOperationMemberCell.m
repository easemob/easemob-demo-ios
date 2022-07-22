//
//  YGCreateGroupOperationMemberCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGCreateGroupOperationMemberCell.h"

#import "BQGroupMemberCell.h"
#import "BQGroupMemberCollectionView.h"

@interface YGCreateGroupOperationMemberCell ()
@property (nonatomic, strong) BQGroupMemberCollectionView* groupMemberView;
@property (nonatomic, strong) EMGroup *group;

@end


@implementation YGCreateGroupOperationMemberCell

- (void)prepare {
    [self.contentView addSubview:self.groupMemberView];
}

- (void)placeSubViews {
    [self.groupMemberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(128.0));
    }];
        
}

- (void)updateWithObj:(id)obj {
    if (obj == nil) {
        return;
    }
    NSMutableArray *tArray = (NSMutableArray *)obj;
    [self.groupMemberView updateUIWithMemberArray:[tArray copy]];
    
    [self.groupMemberView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([YGCreateGroupOperationMemberCell cellHeightWithObj:obj]));
    }];
    
    
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    NSMutableArray *tArray = (NSMutableArray *)obj;
    
    NSInteger rowCount = (tArray.count + 1)/6 + 1;
    if (rowCount == 0) {
        rowCount = 1;
    }
    
    if (rowCount >=3) {
        rowCount = 3;
    }
    
    CGFloat height = 56.0 + rowCount  * [BQGroupMemberCollectionView collectionViewItemSize].height + (rowCount - 1) *[BQGroupMemberCollectionView collectionViewMinimumLineSpacing];
    
    return height;
}

#pragma mark action

#pragma mark getter and setter
- (BQGroupMemberCollectionView *)groupMemberView {
    if (_groupMemberView == nil) {
        _groupMemberView = [[BQGroupMemberCollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        BQ_WS
        _groupMemberView.addMemberBlock = ^{
            if (weakSelf.addMemberBlock) {
                weakSelf.addMemberBlock();
            }
        };
    }
    return _groupMemberView;
}


@end
