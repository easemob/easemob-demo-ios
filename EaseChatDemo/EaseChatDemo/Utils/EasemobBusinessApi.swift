//
//  EasemobBusinessApi.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation

public enum EasemobBusinessApi {
    case login(Void)
    case deregister(String)
    case verificationCode(String)
    case refreshIMToken(Void)
    case autoDestroyGroup(String)
    case fetchGroupAvatar(String)
    case fetchRTCToken(String,String)
    case addFriendByPhoneNumber(String,String)
    case mirrorCallUserIdToChatUserId(String)
}


