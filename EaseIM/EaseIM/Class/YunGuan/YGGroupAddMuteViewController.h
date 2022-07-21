//
//  YGGroupAddBanViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupAddMuteViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) void (^doneCompletion)(NSArray *selectedArray);

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
