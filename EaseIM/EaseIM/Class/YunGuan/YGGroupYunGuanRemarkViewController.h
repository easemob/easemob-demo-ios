//
//  YGGroupYunGuanRemarkViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupYunGuanRemarkViewController : UIViewController
@property (nonatomic, copy) void (^doneCompletion)(NSString *aString);

- (instancetype)initWithSystemmark:(NSString *)aSystemString
                          yGString:(NSString *)aString
                       placeholder:(NSString *)aPlaceholder
                        isEditable:(BOOL)aIsEditable;

@end

NS_ASSUME_NONNULL_END
