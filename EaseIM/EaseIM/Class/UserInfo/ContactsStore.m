//
//  ContactsStore.m
//  EaseIM
//
//  Created by li xiaoming on 2023/9/15.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import "ContactsStore.h"

static ContactsStore *contactsStoreInstance = nil;

@interface ContactsStore ()
@property (nonatomic,strong) NSMutableDictionary* contacts;
@end
@implementation ContactsStore

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactsStoreInstance = [[ContactsStore alloc] init];
    });
    return contactsStoreInstance;
}

- (NSMutableDictionary *)contacts
{
    if (!_contacts) {
        _contacts = [NSMutableDictionary dictionary];
    }
    return _contacts;
}

- (void)loadAllContacts
{
    self.contacts = [EMClient.sharedClient.contactManager getAllContacts];
}

- (void)setContact:(NSString* _Nonnull)userId remark:(NSString*)remark
{
    if(userId.length > 0) {
        if(remark.length <= 0) {
            remark = @"";
        }
        [self.contacts setValue:remark forKey:userId];
    }
}

- (void)setUserContacts:(NSArray<EMContact*>*)contacts
{
    for(EMContact* contact in contacts) {
        [self setContact:contact.userId remark:contact.remark];
    }
}

- (NSString*)remark:(NSString* _Nonnull)userId
{
    if(userId.length > 0) {
        return [self.contacts valueForKey:userId];
    } else {
        return @"";
    }
}
@end
