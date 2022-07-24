//
//  ACDAppStyle.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EMAppLoginType) {
    EMAppLoginTypeNone,
    EMAppLoginTypeJiHu,
    EMAppLoginTypeYunGuan,
};

@interface BQAppStyle : NSObject
//@property (nonatomic, assign) BOOL isJiHuApp;

+ (instancetype)shareAppStyle;
- (void)defaultStyle;
//- (void)saveLoginType;

- (void)updateNavAndTabbarWithIsJihuApp:(BOOL)isJihuApp;

@end

NS_ASSUME_NONNULL_END
