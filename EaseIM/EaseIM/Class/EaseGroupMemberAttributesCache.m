//
//  EaseGroupMemberAttributesCache.m
//  EaseIM
//
//  Created by 朱继超 on 2023/1/16.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import "EaseGroupMemberAttributesCache.h"
#import "NSDictionary+Safely.h"
#import <HyphenateChat/EMError.h>

static EaseGroupMemberAttributesCache *instance = nil;

@interface EaseGroupMemberAttributesCache ()

@property (nonatomic) NSMutableDictionary *attributes;

@end

@implementation EaseGroupMemberAttributesCache

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EaseGroupMemberAttributesCache alloc] init];
    });
    return instance;
}

- (void)removeAllCaches {
    [self.attributes removeAllObjects];
}

- (instancetype)init {
    if ([super init]) {
        _attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)updateCacheWithGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key value:(NSString *)value {
    NSMutableDictionary<NSString*,NSString*> *usesAttributes = [self.attributes objectForKeySafely:groupId];
    if (usesAttributes == nil) {
        usesAttributes = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary<NSString*,NSString*> *attributes = [usesAttributes objectForKeySafely:userName];
    if (attributes == nil) {
        attributes = [NSMutableDictionary dictionary];
    }
    [attributes setObject:value forKeySafely:key];
    [usesAttributes setObject:attributes forKeySafely:userName];
    [self.attributes setObject:usesAttributes forKeySafely:groupId];
}

- (void)updateCacheWithGroupId:(NSString *)groupId userName:(NSString *)userName attributes:(NSDictionary<NSString*,NSString*>*)attributes {
    NSMutableDictionary<NSString*,NSString*> *usesAttributes = [self.attributes objectForKeySafely:groupId];
    if (usesAttributes == nil) {
        usesAttributes = [NSMutableDictionary dictionary];
    }
    [usesAttributes setObject:attributes forKeySafely:userName];
    [self.attributes setObject:usesAttributes forKeySafely:groupId];
}

- (void)removeCacheWithGroupId:(NSString *)groupId {
    [self.attributes setObject:@{} forKeySafely:groupId];
}

- (void)removeCacheWithGroupId:(NSString *)groupId userId:(NSString *)userId {
    [[self.attributes objectForKeySafely:groupId] setObject:@{} forKeySafely:userId];
}

- (void)fetchCacheValueGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key completion:(void(^)(EMError *_Nullable error,NSString * _Nullable value))completion {
    __block NSString *value = [[[self.attributes objectForKeySafely:groupId] objectForKeySafely:userName] objectForKeySafely:key];
    if (value == nil) {
        [EMClient.sharedClient.userInfoManager fetchUserInfoById:@[userName] type:@[@0] completion:^(NSDictionary * _Nullable aUserDatas, EMError * _Nullable aError) {
            if (aError == nil) {
                NSString *nickName = [aUserDatas objectForKeySafely:@"nickName"];
                if (nickName == nil || [nickName isEqualToString:@""]) {
                    [EMClient.sharedClient.groupManager fetchMembersAttributes:groupId userIds:@[userName] keys:@[key] completion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable attributes, EMError * _Nullable error) {
                        if (error == nil) {
                            value = [[attributes objectForKeySafely:userName] objectForKeySafely:key];
                            [self updateCacheWithGroupId:groupId userName:userName key:key value:value];
                        }
                        if (completion) {
                            completion(error,value);
                        }
                    }];
                } else {
                    value = nickName;
                }
            }
        }];
    } else {
        completion(nil,value);
    }
}

- (void)setGroupMemberAttributes:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key value:(NSString *)value completion:(void(^)(EMError *error))completion {
    [EMClient.sharedClient.groupManager setMemberAttribute:groupId userId:userName attributes:@{key:value} completion:^(EMError * _Nullable error) {
        if (error == nil) {
            [self updateCacheWithGroupId:groupId userName:userName key:key value:value];
        }
        if (completion) {
            completion(error);
        }
    }];
}
@end
