//
//  YGGroupSearchTypeTableView.h
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YGSearchGroupType) {
    YGSearchGroupTypeGroupName = 1,
    YGSearchGroupTypeOrderId,
    YGSearchGroupTypePhone,
    YGSearchGroupTypeWINCode,
};

@interface YGGroupSearchTypeTableView : UIView
@property (nonatomic, copy) void (^selectedBlock)(NSString *selectedName, NSInteger selectedType);

@end

NS_ASSUME_NONNULL_END
