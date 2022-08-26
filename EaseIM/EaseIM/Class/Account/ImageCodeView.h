//
//  ImageCodeView.h
//  EaseIM
//
//  Created by li xiaoming on 2022/8/9.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImageCodeViewDelegate <NSObject>

- (void)viewDidClick;

@end

@interface ImageCodeView : UIView
@property (nonatomic,weak) id<ImageCodeViewDelegate> delegate;
@property (nonatomic,weak) NSString* imageCode;
@end

NS_ASSUME_NONNULL_END
