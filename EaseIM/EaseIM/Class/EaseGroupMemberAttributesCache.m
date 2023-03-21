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
#import "UserInfoStore.h"

static EaseGroupMemberAttributesCache *instance = nil;

@interface EaseGroupMemberAttributesCache ()

@property (nonatomic) NSMutableDictionary *attributes;

@property (nonatomic) NSMutableArray *userNames;

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
        _userNames = [NSMutableArray array];
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
    if (![self.userNames containsObject:userName]) {
        [self.userNames addObject:userName];
    } else {
        if (completion) {
            completion(nil,value);
        }
        return;
    }
    if (value == nil) {
        NSString *nickName = [[UserInfoStore sharedInstance] getUserInfoById:userName].nickname;
        if (nickName == nil || [nickName isEqualToString:@""]) {
            [EMClient.sharedClient.groupManager fetchMembersAttributes:groupId userIds:self.userNames keys:@[key] completion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable attributes, EMError * _Nullable error) {
                if (error == nil) {
                    for (NSString *userNameKey in attributes.allKeys) {
                        NSDictionary<NSString *,NSString *> *dic = [attributes objectForKeySafely:userNameKey];
                        for (NSString *valueKey in dic.allKeys) {
                            NSString *realValue = [attributes objectForKeySafely:valueKey];
                            [self updateCacheWithGroupId:groupId userName:userNameKey key:valueKey value:realValue];
                        }
                    }
                    
                }
                [self.userNames removeObject:attributes.allKeys.firstObject];
                if (completion) {
                    completion(error,value);
                }
            }];
        } else {
            value = nickName;
        }
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
