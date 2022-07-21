//
//  BQGroupMemberView.h
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BQGroupMemberCollectionView : UIView
@property (nonatomic, copy) void (^addMemberBlock)(void);
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;

+ (CGSize)collectionViewItemSize;

+ (CGFloat)collectionViewMinimumLineSpacing;

- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray;

@end

NS_ASSUME_NONNULL_END
