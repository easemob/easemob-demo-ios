//
//  EMContactModel.h
//  EaseIM
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMContactModel : NSObject <EaseUserDelegate>
@property (nonatomic, strong) NSString *huanXinId;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *nickname;

- (UIImage *)defaultAvatar;
- (NSString *)showName;
@end

NS_ASSUME_NONNULL_END
