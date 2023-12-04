//
//  ContactsStore.h
//  EaseIM
//
//  Created by li xiaoming on 2023/9/15.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsStore : NSObject
+ (instancetype)sharedInstance;
- (void)loadAllContacts;
- (void)setContact:(NSString* _Nonnull)userId remark:(NSString*)remark;
- (void)setUserContacts:(NSArray<EMContact*>*)contacts;
- (NSString*)remark:(NSString* _Nonnull)userId;
@end

NS_ASSUME_NONNULL_END
