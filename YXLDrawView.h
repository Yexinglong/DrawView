//
//  YXLDrawView.m
//  我滴小画板
//
//  Created by YXL on 16/3/25.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface YXLDrawView : UIView
/**
 *  线宽
 */
@property (nonatomic, assign) CGFloat lineWidth;
/**
 *  线颜色
 */
@property (nonatomic, strong) NSString *lineColor;
/**
 *  线的透明度
 */
@property (nonatomic, assign) CGFloat lineAlpha;
/**
 *  橡皮擦
 */
@property (nonatomic, assign) BOOL isErase;
/**
 *  堆栈
 */
-(BOOL)isUndo;
-(BOOL)isRedo;

/**
 *  针对撤销与恢复的回调
 */
@property (nonatomic ,copy) void(^endBlock)();
/**
 *  撤销
 */
- (void)undo;

/**
 *  恢复
 */
- (void)redo;
@end

@interface YXLBezierPath : UIBezierPath
+ (instancetype)paintPathWithLineWidth:(CGFloat)width
                            startPoint:(CGPoint)startP;
@end


