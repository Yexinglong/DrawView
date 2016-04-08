//
//  UIColor+RandomColor.h
//  我滴小画板
//
//  Created by 叶星龙 on 15/11/28.
//  Copyright © 2015年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RandomColor)
+(UIColor *) randomColor;
+ (UIColor *) colorWithHexString: (NSString *)color;
+ (UIColor *) colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;
- (NSString *)toColorString;
@end
