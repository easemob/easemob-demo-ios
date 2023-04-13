//
//  EaseGroupMemberAttributesCache.h
//  EaseIM
//
//  Created by 朱继超 on 2023/1/16.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseGroupMemberAttributesCache :NSObject

+ (instancetype)shareInstance;

- (void)updateCacheWithGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key value:(NSString *)value;

- (void)removeCacheWithGroupId:(NSString *)groupId;

- (void)removeCacheWithGroupId:(NSString *)groupId userId:(NSString *)userId;

- (void)fetchCacheValueGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key completion:(void(^)(EMError *_Nullable error,NSString * _Nullable value))completion;

- (void)removeAllCaches;

@end

NS_ASSUME_NONNULL_END
