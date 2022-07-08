/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#ifndef BQDemoUIDefine_h
#define BQDemoUIDefine_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define AgoraChatVIEWTOPMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX KScreenWidth >=375.0f && KScreenHeight >=812.0f&& kIs_iphone
 
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))
#define kNavBarHeight (44)

#define kNavBarAndStatusBarHeight (CGFloat)(kIs_iPhoneX?(88.0):(64.0))

#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))

#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX?(44.0):(0))

#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))

#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX?(24.0):(0))

#define kNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define COLOR_HEXA(__RGB,__ALPHA) [UIColor colorWithRed:((float)((__RGB & 0xFF0000) >> 16))/255.0 green:((float)((__RGB & 0xFF00) >> 8))/255.0 blue:((float)(__RGB & 0xFF))/255.0 alpha:__ALPHA]

#define COLOR_HEX(__RGB) COLOR_HEXA(__RGB,1.0f)

//weak & strong self
#define BQ_WS                  __weak __typeof(&*self)weakSelf = self;
#define BQ_SS(WKSELF)          __strong __typeof(&*self)strongSelf = WKSELF;

#define BQ_ONE_PX  (1.0f / [UIScreen mainScreen].scale)

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_UPDATEUNREADCOUNT @"setupUnreadMessageCount"
#define KNOTIFICATIONNAME_DELETEALLMESSAGE @"RemoveAllMessages"
#define KNOTIFICATION_CALL @"callOutWithChatter"

#define  AGORACHATDEMO_POSTNOTIFY(name,object)  [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];

#define  AGORACHATDEMO_LISTENNOTIFY(name,SEL)  [[NSNotificationCenter defaultCenter] addObserver:self selector:SEL name:name object:nil];
  

#define ImageWithName(imageName) [UIImage imageNamed:imageName]

#define kAgroaPadding 10.0f
#define kAvatarHeight 32.0f
#define kContactAvatarHeight 40.0f
#define kSearchBarHeight 32.0
#define kBQPadding 10.0



//user
#define USER_NAME @"user_name"
#define USER_NICKNAME @"nick_name"

//fonts
#define NFont(__SIZE) [UIFont systemFontOfSize:__SIZE] //system font with size
#define IFont(__SIZE) [UIFont italicSystemFontOfSize:__SIZE] //system font with size
#define BFont(__SIZE) [UIFont boldSystemFontOfSize:__SIZE]//system bold font with size
#define Font(__NAME, __SIZE) [UIFont fontWithName:__NAME size:__SIZE] //font with name and size

//message recall
#define MSG_EXT_RECALL @"agora_recall"


#define TextLabelBlueColor  COLOR_HEX(0x154DFE)
#define TextLabelGrayColor  COLOR_HEX(0x999999)
#define TextLabelPlaceHolderGrayColor  COLOR_HEX(0xE6E6E6)
#define TextLabelBlackColor  COLOR_HEX(0x000000)
#define TextLabelBlack2Color  COLOR_HEX(0x0D0D0D)
#define TextLabelPinkColor  COLOR_HEX(0xFF14CC)
#define TextLabelWhiteColor  UIColor.whiteColor


#define InputGrayColor  COLOR_HEX(0x3D3D3D)

#define ViewBgBlackColor  COLOR_HEX(0x171717)


#endif /* BQDemoUIDefine_h */
