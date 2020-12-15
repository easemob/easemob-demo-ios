//
//  EMUserDataModel.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/12/3.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseIMKit/EaseIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMUserDataModel : NSObject <EaseUserDelegate>
@property (nonatomic, copy) NSString *easeId;           // 环信id
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示

- (instancetype)initWithHuanxinId:(NSString *)huanxinId;
@end

NS_ASSUME_NONNULL_END
