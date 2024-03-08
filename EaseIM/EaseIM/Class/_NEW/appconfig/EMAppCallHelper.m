//
//  EMAppCallHelper.m
//  EaseIM
//
//  Created by yangjian on 2022/7/27.
//  Copyright © 2022 yangjian. All rights reserved.
//

#import "EMAppCallHelper.h"



static EMAppCallHelper *callHelper = nil;

@implementation EMAppCallHelper

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callHelper = [[EMAppCallHelper alloc] init];
    });
    return callHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)dealloc{
    
}


#pragma delegate
//- (void)callDidEnd:(NSString*)aChannelName reason:(EaseCallEndReason)aReason time:(int)aTm type:(EaseCallType)aCallType
//{
//    NSString* msg = @"";
//    switch (aReason) {
//        case EaseCallEndReasonHandleOnOtherDevice:
//            msg = NSLocalizedString(@"otherDevice", nil);
//            break;
//        case EaseCallEndReasonBusy:
//            msg = NSLocalizedString(@"remoteBusy", nil);
//            break;
//        case EaseCallEndReasonRefuse:
//            msg = NSLocalizedString(@"refuseCall", nil);
//            break;
//        case EaseCallEndReasonCancel:
//            msg = NSLocalizedString(@"cancelCall", nil);
//            break;
//        case EaseCallEndReasonRemoteCancel:
//            msg = NSLocalizedString(@"callCancel", nil);
//            break;
//        case EaseCallEndReasonRemoteNoResponse:
//            msg = NSLocalizedString(@"remoteNoResponse", nil);
//            break;
//        case EaseCallEndReasonNoResponse:
//            msg = NSLocalizedString(@"noResponse", nil);
//            break;
//        case EaseCallEndReasonHangup:
//            msg = [NSString stringWithFormat:NSLocalizedString(@"callendPrompt", nil),aTm];
//            break;
//        default:
//            break;
//    }
//    if([msg length] > 0)
//       [self showHint:msg];
//}
// 多人音视频邀请按钮的回调
//- (void)multiCallDidInvitingWithCurVC:(UIViewController*_Nonnull)vc excludeUsers:(NSArray<NSString*> *_Nullable)users ext:(NSDictionary *)aExt
//{
//    NSString* groupId = nil;
//    if(aExt) {
//        groupId = [aExt objectForKey:@"groupId"];
//    }
//    
//    ConfInviteUsersViewController * confVC = nil;
//    if([groupId length] == 0) {
//        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeUser isCreate:NO excludeUsers:users groupOrChatroomId:nil];
//    }else{
//        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeGroup isCreate:NO excludeUsers:users groupOrChatroomId:groupId];
//    }
//    
//    [confVC setDoneCompletion:^(NSArray *aInviteUsers) {
//        for (NSString* strId in aInviteUsers) {
//            EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:strId];
//            if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
//                EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
//                [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:strId info:user];
//            }
//        }
//        [[EaseCallManager sharedManager] startInviteUsers:aInviteUsers ext:aExt completion:nil];
//    }];
//    confVC.modalPresentationStyle = UIModalPresentationPopover;
//    [vc presentViewController:confVC animated:NO completion:nil];
//}
// 振铃时增加回调
//- (void)callDidReceive:(EaseCallType)aType inviter:(NSString*_Nonnull)username ext:(NSDictionary*)aExt
//{
//    EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
//    if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
//        EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
//        [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
//    }
//}

//// 异常回调
//- (void)callDidOccurError:(EaseCallError *)aError
//{
//    
//}

//- (void)callDidRequestRTCTokenForAppId:(NSString *)aAppId channelName:(NSString *)aChannelName account:(NSString *)aUserAccount uid:(NSInteger)aAgoraUid
//{
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
//                                                          delegate:nil
//                                                     delegateQueue:[NSOperationQueue mainQueue]];
//
//    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
//    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//    NSURL* url = [NSURL URLWithString:utf8Url];
//    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
//    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken] forHTTPHeaderField:@"Authorization"];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data) {
//            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"%@",body);
//            if(body) {
//                NSString* resCode = [body objectForKey:@"code"];
//                if([resCode isEqualToString:@"RES_0K"]) {
//                    NSString* rtcToken = [body objectForKey:@"accessToken"];
//                    NSNumber* uid = [body objectForKey:@"agoraUserId"];
//                    [[EaseCallManager sharedManager] setRTCToken:rtcToken channelName:aChannelName uid:[uid unsignedIntegerValue]];
//                }
//            }
//        }
//        
//        
//    }];
//
//    [task resume];
//}

//-(void)remoteUserDidJoinChannel:( NSString*_Nonnull)aChannelName uid:(NSInteger)aUid username:(NSString*_Nullable)aUserName
//{
//    if(aUserName.length > 0) {
//        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUserName];
//        if(userInfo && (userInfo.avatarUrl.length > 0 || userInfo.nickName.length > 0)) {
//            EaseCallUser* user = [EaseCallUser userWithNickName:userInfo.nickName image:[NSURL URLWithString:userInfo.avatarUrl]];
//            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:aUserName info:user];
//        }
//    }else{
//        [self _fetchUserMapsFromServer:aChannelName];
//    }
//}
//
//- (void)callDidJoinChannel:(NSString*_Nonnull)aChannelName uid:(NSUInteger)aUid
//{
//    [self _fetchUserMapsFromServer:aChannelName];
//}
//
//- (void)_fetchUserMapsFromServer:(NSString*)aChannelName
//{
//    // 这里设置映射表，设置头像，昵称
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
//                                                          delegate:nil
//                                                     delegateQueue:[NSOperationQueue mainQueue]];
//
//    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/channel/mapper?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
//    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//    NSURL* url = [NSURL URLWithString:utf8Url];
//    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
//    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data) {
//            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"mapperBody:%@",body);
//            if(body) {
//                NSString* resCode = [body objectForKey:@"code"];
//                if([resCode isEqualToString:@"RES_0K"]) {
//                    NSString* channelName = [body objectForKey:@"channelName"];
//                    NSDictionary* result = [body objectForKey:@"result"];
//                    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
//                    for (NSString* strId in result) {
//                        NSString* username = [result objectForKey:strId];
//                        NSNumber* uId = [NSNumber numberWithInteger:[strId integerValue]];
//                        [users setObject:username forKey:uId];
//                        EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
//                        if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
//                            EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
//                            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
//                        }
//                    }
//                    [[EaseCallManager sharedManager] setUsers:users channelName:channelName];
//                }
//            }
//        }
//    }];
//
//    [task resume];
//}

//
//- (void)showHint:(NSString *)hint
//{
//    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
//    hud.userInteractionEnabled = NO;
//    // Configure for text only and offset down
//    hud.mode = MBProgressHUDModeText;
//    hud.label.text = hint;
//    hud.margin = 10.f;
//    CGPoint offset = hud.offset;
//    offset.y = 180;
//    hud.offset = offset;
//    hud.removeFromSuperViewOnHide = YES;
//    [hud hideAnimated:YES afterDelay:2];
//}




//calldelegate
- (void)callDidEnd:(NSString*)aChannelName reason:(EaseCallEndReason)aReason time:(int)aTm type:(EaseCallType)aCallType
{
    NSString* msg = @"";
    switch (aReason) {
        case EaseCallEndReasonHandleOnOtherDevice:
            msg = NSLocalizedString(@"otherDevice", nil);
            break;
        case EaseCallEndReasonBusy:
            msg = NSLocalizedString(@"remoteBusy", nil);
            break;
        case EaseCallEndReasonRefuse:
            msg = NSLocalizedString(@"refuseCall", nil);
            break;
        case EaseCallEndReasonCancel:
            msg = NSLocalizedString(@"cancelCall", nil);
            break;
        case EaseCallEndReasonRemoteCancel:
            msg = NSLocalizedString(@"callCancel", nil);
            break;
        case EaseCallEndReasonRemoteNoResponse:
            msg = NSLocalizedString(@"remoteNoResponse", nil);
            break;
        case EaseCallEndReasonNoResponse:
            msg = NSLocalizedString(@"noResponse", nil);
            break;
        case EaseCallEndReasonHangup:
            msg = [NSString stringWithFormat:NSLocalizedString(@"callendPrompt", nil),aTm];
            break;
        default:
            break;
    }
    if([msg length] > 0)
       [self showHint:msg];
}
// 多人音视频邀请按钮的回调
- (void)multiCallDidInvitingWithCurVC:(UIViewController*_Nonnull)vc excludeUsers:(NSArray<NSString*> *_Nullable)users ext:(NSDictionary *)aExt
{
    NSString* groupId = nil;
    if(aExt) {
        groupId = [aExt objectForKey:@"groupId"];
    }
    
    ConfInviteUsersViewController * confVC = nil;
    if([groupId length] == 0) {
        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeUser isCreate:NO excludeUsers:users groupOrChatroomId:nil];
    }else{
        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeGroup isCreate:NO excludeUsers:users groupOrChatroomId:groupId];
    }
    
    [confVC setDoneCompletion:^(NSArray *aInviteUsers) {
        for (NSString* strId in aInviteUsers) {
            EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:strId];
            if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
                EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
                [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:strId info:user];
            }
        }
        [[EaseCallManager sharedManager] startInviteUsers:aInviteUsers ext:aExt completion:nil];
    }];
    confVC.modalPresentationStyle = UIModalPresentationPopover;
    [vc presentViewController:confVC animated:NO completion:nil];
}
// 振铃时增加回调
- (void)callDidReceive:(EaseCallType)aType inviter:(NSString*_Nonnull)username ext:(NSDictionary*)aExt
{
    EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
    if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
        EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
        [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
    }
}

// 异常回调
- (void)callDidOccurError:(EaseCallError *)aError
{
    
}

- (void)callDidRequestRTCTokenForAppId:(NSString *)aAppId channelName:(NSString *)aChannelName account:(NSString *)aUserAccount uid:(NSInteger)aAgoraUid
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* rtcToken = [body objectForKey:@"accessToken"];
                    NSNumber* uid = [body objectForKey:@"agoraUserId"];
                    [[EaseCallManager sharedManager] setRTCToken:rtcToken channelName:aChannelName uid:[uid unsignedIntegerValue]];
                }
            }
        }
        
        
    }];

    [task resume];
}

-(void)remoteUserDidJoinChannel:( NSString*_Nonnull)aChannelName uid:(NSInteger)aUid username:(NSString*_Nullable)aUserName
{
    if(aUserName.length > 0) {
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUserName];
        if(userInfo && (userInfo.avatarUrl.length > 0 || userInfo.nickname.length > 0)) {
            EaseCallUser* user = [EaseCallUser userWithNickName:userInfo.nickname image:[NSURL URLWithString:userInfo.avatarUrl]];
            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:aUserName info:user];
        }
    }else{
        [self _fetchUserMapsFromServer:aChannelName];
    }
}

- (void)callDidJoinChannel:(NSString*_Nonnull)aChannelName uid:(NSUInteger)aUid
{
    [self _fetchUserMapsFromServer:aChannelName];
}

- (void)_fetchUserMapsFromServer:(NSString*)aChannelName
{
    // 这里设置映射表，设置头像，昵称
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/channel/mapper?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"mapperBody:%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* channelName = [body objectForKey:@"channelName"];
                    NSDictionary* result = [body objectForKey:@"result"];
                    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
                    for (NSString* strId in result) {
                        NSString* username = [result objectForKey:strId];
                        NSNumber* uId = [NSNumber numberWithInteger:[strId integerValue]];
                        [users setObject:username forKey:uId];
                        EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
                        if(info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
                            EaseCallUser* user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
                        }
                    }
                    [[EaseCallManager sharedManager] setUsers:users channelName:channelName];
                }
            }
        }
    }];

    [task resume];
}


- (void)showHint:(NSString *)hint
{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    CGPoint offset = hud.offset;
    offset.y = 180;
    hud.offset = offset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}


@end
