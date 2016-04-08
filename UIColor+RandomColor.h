//
//  UIColor+RandomColor.h
//  几何
//
//  Created by 叶星龙 on 15/11/28.
//  Copyright © 2015年 北京声赞科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RandomColor)
+(UIColor *) randomColor;
+ (UIColor *) colorWithHexString: (NSString *)color;
+ (UIColor *) colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;
- (NSString *)toColorString;
@end
