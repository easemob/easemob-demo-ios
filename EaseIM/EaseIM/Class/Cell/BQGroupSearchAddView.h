//
//  BQGroupSearchAddedView.h
//  EaseIM
//
//  Created by liu001 on 2022/7/10.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BQGroupSearchAddViewDelegate <NSObject>

- (void)heightForGroupSearchAddView:(CGFloat)height;

@end


@interface BQGroupSearchAddView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) void (^deleteMemberBlock)(NSString *userId);
@property (nonatomic, assign) id<BQGroupSearchAddViewDelegate> delegate;

- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray;


@end

NS_ASSUME_NONNULL_END
