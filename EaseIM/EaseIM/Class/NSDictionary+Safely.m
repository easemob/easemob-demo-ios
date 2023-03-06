//
//  NSDictionary+Safely.m
//  EaseIM
//
//  Created by 朱继超 on 2023/1/16.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import "NSDictionary+Safely.h"

@implementation NSDictionary (Safely)

- (void)printNotValidKeyError:(const char *)fuction
{
    [[self class] printNotValidKeyError:fuction];
}

+ (void)printNotValidKeyError:(const char *)fuction
{
    NSLog(@"%s \n key is not confirm NSCopying protocol \n Dictionary:%@",fuction ,self);
}

- (void)printNilKeyError:(const char *)fuction
{
    [[self class] printNilKeyError:fuction];
}

- (void)printNilObjectError:(const char *)fuction
{
    [[self class] printNilObjectError:fuction];
}

+ (void)printNilObjectError:(const char *)fuction
{
    NSLog(@"%s \n object is nil \n Dictionary:%@",fuction ,self);
}

+ (void)printNilKeyError:(const char *)fuction
{
    NSLog(@"%s \n key is nil \n Dictionary:%@",fuction ,self);
}

- (id)valueForKeySafely:(id)aKey
{
    if (!aKey) {
        [self printNilKeyError:__FUNCTION__];
        return nil;
    }
    return [self valueForKey:aKey];
}

- (id)objectForKeySafely:(id)aKey
{
    if (!aKey) {
        [self printNilKeyError:__FUNCTION__];
        return nil;
    }
    return [self objectForKey:aKey];
}

+ (instancetype)dictionaryWithObject:(id)object forKeySafely:(id <NSCopying>)key
{
    if (!object) {
        [self printNilObjectError:__FUNCTION__];
        return [[self class] dictionary];
    }
    if (!key) {
        [self printNilKeyError:__FUNCTION__];
        return [[self class] dictionary];
    }
    return [self dictionaryWithObject:object forKey:key];
}


//
//+ (instancetype)swizzled_m_dictionaryWithObjects:(ConstIDCArray)objects forKeys:(const id [])keys count:(NSUInteger)cnt
//{
//    if (cnt == 0) {
//        return [[self class] dictionary];
//    }
//
//    if (objects) {
//        if ([self hasNilObject:objects count:cnt]) {
//            [self printNilObjectError:__FUNCTION__];
//            return [[self class] dictionary];
//        }
//    }
//
//    if (keys) {
//        if ([self hasNilObject:keys count:cnt]) {
//            [self printNilObjectError:__FUNCTION__];
//            return [[self class] dictionary];
//        }
//    }
//
//    return [self swizzled_m_dictionaryWithObjects:objects forKeys:keys count:cnt];
//}
//
//+ (instancetype)swizzled_i_dictionaryWithObjects:(ConstIDCArray)objects forKeys:(const id [])keys count:(NSUInteger)cnt
//{
//    if (cnt == 0) {
//        return [[self class] dictionary];
//    }
//
//    if (objects) {
//        if ([self hasNilObject:objects count:cnt]) {
//            [self printNilObjectError:__FUNCTION__];
//            return [[self class] dictionary];
//        }
//    }
//
//    if (keys) {
//        if ([self hasNilObject:keys count:cnt]) {
//            [self printNilObjectError:__FUNCTION__];
//            return [[self class] dictionary];
//        }
//    }
//
//    return [self swizzled_i_dictionaryWithObjects:objects forKeys:keys count:cnt];
//}

/*
 
- (instancetype)swizzled_i_initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    if (cnt == 0) {
        return [[[self class] alloc] init];
    }
    
    if (objects) {
        if ([self hasNilObject:objects count:cnt]) {
            [self printNilObjectError:__FUNCTION__];
            return [[[self class] alloc] init];
        }
    }
    
    if (objects) {
        if ([self hasNilObject:keys count:cnt]) {
            [self printNilObjectError:__FUNCTION__];
            return [[[self class] alloc] init];
        }
    }
    
    return [self swizzled_i_initWithObjects:objects forKeys:keys count:cnt];
}

- (instancetype)swizzled_m_initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    if (cnt == 0) {
        return [[[self class] alloc] init];
    }
    
    if (objects) {
        if ([self hasNilObject:objects count:cnt]) {
            [self printNilObjectError:__FUNCTION__];
            return [[[self class] alloc] init];
        }
    }
    
    if (objects) {
        if ([self hasNilObject:keys count:cnt]) {
            [self printNilObjectError:__FUNCTION__];
            return [[[self class] alloc] init];
        }
    }
    
    return [self swizzled_m_initWithObjects:objects forKeys:keys count:cnt];
}

*/

@end


@implementation NSMutableDictionary (Safely)

//+ (instancetype)dictionaryWithObjectsAndKeysSafely:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION
//{
//    if (!firstObject) return [NSMutableDictionary dictionary];
//
//    NSMutableArray *keys = [NSMutableArray array];
//    NSMutableArray *values = [NSMutableArray array];
//
//
//    id obj = firstObject;
//    BOOL isKey = YES;
//    va_list objects;
//    va_start(objects, obj);
//    do
//    {
//        if (isKey)
//        {
//            [keys addObjectSafely:obj];
//        }
//        else
//        {
//            [values addObjectSafely:obj];
//        }
//        obj = va_arg(objects, id);
//        isKey = !isKey;
//    } while (obj);
//    va_end(objects);
//
//    if (keys.count == values.count) {
//        return [NSMutableDictionary dictionaryWithObject:values forKey:keys];
//    }
//    return nil;
//}

- (void)removeObjectForKeySafely:(id)aKey
{

    
    if (!aKey)
    {
        [self printNilKeyError:__FUNCTION__];
        return;
    }
    [self removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKeySafely:(id <NSCopying>)aKey
{
    if (!anObject) {
        [self printNilObjectError:__FUNCTION__];
        return;
    }
    
    if (!aKey) {
        [self printNilKeyError:__FUNCTION__];
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

- (void)setValue:(id)value forKeySafely:(NSString *)key
{
    if (!value) {
        [self printNilObjectError:__FUNCTION__];
        return;
    }
    
    if (!key) {
        [self printNilKeyError:__FUNCTION__];
        return;
    }
    return [self setValue:value forKey:key];
}
@end

