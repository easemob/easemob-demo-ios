//
//  UserInfoStore.m
//  EaseIM
//
//  Created by lixiaoming on 2021/3/18.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "UserInfoStore.h"
#import "DBManager.h"

@interface UserInfoStore()
@property (nonatomic,strong) NSMutableDictionary* dicUsersInfo;
@property (nonatomic) NSTimeInterval timeOutInterval;
@property (atomic,strong) NSMutableArray* userIds;
@property (nonatomic,strong) NSLock* lock;
@property (nonatomic,strong) NSLock* userInfolock;
@property (nonatomic,strong) dispatch_queue_t workQueue;
@end

static UserInfoStore *userInfoStoreInstance = nil;

@implementation UserInfoStore

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfoStoreInstance = [[UserInfoStore alloc] init];
        userInfoStoreInstance.timeOutInterval = 24*3600;
        userInfoStoreInstance.lock = [[NSLock alloc] init];
        userInfoStoreInstance.userInfolock = [[NSLock alloc] init];
        userInfoStoreInstance.workQueue = dispatch_queue_create("demo.userinfostore", DISPATCH_QUEUE_SERIAL);
    });
    return userInfoStoreInstance;
}

- (void)setUserInfo:(EMUserInfo*)aUserInfo forId:(NSString*)aUserId
{
    [self.userInfolock lock];
    if(aUserId.length > 0 && aUserInfo)
    {
        [self.dicUsersInfo setObject:aUserInfo forKey:aUserId];
        [[DBManager sharedInstance] addUserInfos:@[aUserInfo]];
    }
    [self.userInfolock unlock];
}

- (void)setUserInfo:(EMUserInfo*)aUserInfo type:(EMUserInfoType)aType forId:(NSString*)aUserId
{
    [self.userInfolock lock];
    if(aUserId.length > 0 && aUserInfo)
    {
        EMUserInfo* info = [self.dicUsersInfo objectForKey:aUserId];
        if(info) {
            switch (aType) {
                case EMUserInfoTypeAvatarURL:
                    info.avatarUrl = aUserInfo.avatarUrl;
                    break;
                case EMUserInfoTypeNickName:
                    info.nickname = aUserInfo.nickname;
                    break;
                case EMUserInfoTypeMail:
                    info.mail = aUserInfo.mail;
                    break;
                case EMUserInfoTypePhone:
                    info.phone = aUserInfo.phone;
                    break;
                case EMUserInfoTypeExt:
                    info.ext = aUserInfo.ext;
                    break;
                case EMUserInfoTypeSign:
                    info.sign = aUserInfo.sign;
                    break;
                case EMUserInfoTypeBirth:
                    info.birth = aUserInfo.birth;
                    break;
                case EMUserInfoTypeGender:
                    info.gender = aUserInfo.gender;
                    break;
                default:
                    break;
            }
        }else{
            info = aUserInfo;
        }
        [self.dicUsersInfo setObject:info forKey:aUserId];
        [[DBManager sharedInstance] addUserInfos:@[info]];
    }
    [self.userInfolock unlock];
}
- (void)addUserInfos:(NSArray<EMUserInfo*>*)aUserInfos
{
    [self.userInfolock lock];
    if(aUserInfos.count > 0) {
        for (EMUserInfo* userInfo in aUserInfos) {
            if(userInfo && userInfo.userId.length > 0 )
            {
                [self.dicUsersInfo setObject:userInfo forKey:userInfo.userId];
            }
        }
        [[DBManager sharedInstance] addUserInfos:aUserInfos];
    }
    [self.userInfolock unlock];
}
- (EMUserInfo*)getUserInfoById:(NSString*)aUserId
{
    
    if(aUserId.length > 0)
    {
        [self.userInfolock lock];
        EMUserInfo* userInfo = [self.dicUsersInfo objectForKey:aUserId];
        [self.userInfolock unlock];
        return userInfo;
    }
    return nil;
}

- (NSMutableDictionary*)dicUsersInfo
{
    if(!_dicUsersInfo){
        _dicUsersInfo = [NSMutableDictionary dictionary];
    }
    return  _dicUsersInfo;
}

-(NSMutableArray*)userIds
{
    if(!_userIds) {
        _userIds = [NSMutableArray array];
    }
    return _userIds;
}

- (void)loadInfosFromLocal
{
    NSArray<EMUserInfo*>* array = [[DBManager sharedInstance] loadUserInfos];
    [self addUserInfos:array];
}

- (NSArray*) splitArrayWithArray:(NSArray*)rawArray rangeNumber:(int)rangeNumber{
    NSUInteger totalCount = rawArray.count;
    NSUInteger currentIndex = 0;
    NSMutableArray* splitArray = [NSMutableArray array];
    while (currentIndex < totalCount) {
        NSRange range = NSMakeRange(currentIndex, MIN(rangeNumber, totalCount-currentIndex));
        NSArray* subArray = [rawArray subarrayWithRange:range];
        [splitArray addObject:subArray];
        currentIndex +=rangeNumber;
    }
    return splitArray;
}

- (void)fetchAction
{
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), self.workQueue, ^{
        // 每次最多获取100个，分组获取
        NSArray* splitArrays = [self splitArrayWithArray:weakself.userIds rangeNumber:100];
        for (NSArray* uids in splitArrays) {
            [[[EMClient sharedClient] userInfoManager] fetchUserInfoById:uids completion:^(NSDictionary *aUserDatas, EMError *aError) {
                if(!aError && aUserDatas.count > 0) {
                    NSMutableArray* arrayUserInfo = [NSMutableArray array];
                    for (NSString* uid in aUserDatas) {
                        EMUserInfo* userInfo = [aUserDatas objectForKey:uid];
                        if(uid.length > 0 && userInfo)
                        {
                            [arrayUserInfo addObject:userInfo];
                        }
                        [weakself.lock lock];
                        [weakself.userIds removeObject:uid];
                        [weakself.lock unlock];
                    }
                    [self addUserInfos:arrayUserInfo];
                    if(arrayUserInfo.count > 0)
                        [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil];
                }
            }];
        }
    });
}

- (void)fetchUserInfosFromServer:(NSArray<NSString*>*)aUids
{
    [self.lock lock];
    BOOL add = NO;
    for (NSString* uid in aUids) {
        if(![self.userIds containsObject:uid])
        {
            [self.userIds addObject:uid];
            add = YES;
        }
    }
    [self.lock unlock];
    if (!add) {
        return;
    }
    
    // 延迟执行获取用户属性
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchAction) object:nil];
        [self performSelector:@selector(fetchAction) withObject:nil afterDelay:0.5f];
    });
    
}

@end
