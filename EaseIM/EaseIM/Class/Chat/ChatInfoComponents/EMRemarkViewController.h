//
//  EMRemarkViewController.h
//  EaseIM
//
//  Created by li xiaoming on 2023/9/15.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMRemarkViewController : UIViewController
- (instancetype)initWithUserId:(NSString*)userId remark:(NSString * _Nullable)remark complete:(void (^)(NSString *remark))complete;
@end

NS_ASSUME_NONNULL_END
