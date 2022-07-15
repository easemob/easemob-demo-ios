//
//  BQConfenceSelectedView.h
//  EaseIM
//
//  Created by liu001 on 2022/7/14.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BQConfInviteSelectedUsersView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;

- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray;

@end

NS_ASSUME_NONNULL_END
