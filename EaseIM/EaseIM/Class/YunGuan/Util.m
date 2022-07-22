//
//  Util.m
//  EaseIM
//
//  Created by liu001 on 2022/7/22.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}


@end
