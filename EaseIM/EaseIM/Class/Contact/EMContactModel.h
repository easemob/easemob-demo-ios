//
//  EMContactModel.h
//  EaseIM
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMContactModel : NSObject <EaseUserDelegate>
@property (nonatomic, strong) NSString *easeId;
@property (nonatomic, strong) UIImage *defaultAvatar;
@property (nonatomic, strong) NSString *showName;

- (UIImage *)defaultAvatar;
- (NSString *)showName;
@end

NS_ASSUME_NONNULL_END
