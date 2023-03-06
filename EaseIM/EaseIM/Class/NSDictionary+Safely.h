//
//  NSDictionary+Safely.h
//  EaseIM
//
//  Created by 朱继超 on 2023/1/16.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Safely)
- (id)valueForKeySafely:(id)aKey;

- (id)objectForKeySafely:(id)aKey;

+ (instancetype)dictionaryWithObject:(id)object forKeySafely:(id <NSCopying>)key;
@end

@interface NSMutableDictionary (Safely)
//+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (void)removeObjectForKeySafely:(id)aKey;
- (void)setObject:(id)anObject forKeySafely:(id <NSCopying>)aKey;

- (void)setValue:(id)value forKeySafely:(NSString *)key;

@end


NS_ASSUME_NONNULL_END
