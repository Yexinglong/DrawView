//
//  YXLDrawView.m
//  我滴小画板
//
//  Created by YXL on 16/3/25.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import "YXLDrawView.h"
#import "UIColor+RandomColor.h"
@class YXLBezierPath;

@interface YXLDrawView (){
    CGPoint pointsArray[5];
    UIImage *curImage;
   
}

@property (nonatomic ,strong) NSUndoManager *undoManagerLine;
@property (nonatomic ,strong) NSUndoManager *undoManagerTpme;
@property (nonatomic, strong) YXLBezierPath * path;
@property (nonatomic, strong) CAShapeLayer * slayer;

@end

@implementation YXLDrawView

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.undoManagerLine = [[NSUndoManager alloc] init];
        [self.undoManagerLine setLevelsOfUndo:MAXFLOAT];
        self.undoManagerTpme= [[NSUndoManager alloc] init];
        [self.undoManagerTpme setLevelsOfUndo:MAXFLOAT];

        _lineWidth = 1;
        _lineAlpha = 0;
        _lineColor = @"000000";
        self.backgroundColor=[UIColor clearColor];

    
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [curImage drawAtPoint:CGPointMake(0, 0)];
    /**
     *  开启了橡皮擦时,使用这种方式能实现真正的擦除
     */
    if (_isErase) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        CGPoint mid1    = midPoint(pointsArray[1], pointsArray[2]);
        CGPoint mid2    = midPoint(pointsArray[0], pointsArray[1]);
        CGContextMoveToPoint(context, mid1.x, mid1.y);
        CGContextAddQuadCurveToPoint(context, pointsArray[1].x, pointsArray[1].y, mid2.x, mid2.y);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextSetShouldAntialias(context, YES);
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetFlatness(context, 0.1f);
        CGContextStrokePath(context);
    }
    [super drawRect:rect];
}

/**
 *  手势开始
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([event allTouches].count>=2) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint startP = [touch locationInView:self];
    if ([event allTouches].count == 1) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[self.undoManagerLine prepareWithInvocationTarget:self] setImage:curImage];
        [self.undoManagerTpme removeAllActions];
        _path = [YXLBezierPath paintPathWithLineWidth:self.lineWidth
                                                       startPoint:startP];
        pointsArray[1] = [touch previousLocationInView:self];
        pointsArray[2] = [touch previousLocationInView:self];
        pointsArray[0] = [touch locationInView:self];
        if (!_isErase) {
            /**
             *  使用CAShapeLayer来做绘制路径，是目前比较合适的一种方式，如果绘制一层话,这样不会造成GPU过高，使用CAShapeLayer是不能实现真正的橡皮擦的，所以我以图片的形式，放在上下文,然后在将当前CAShapeLayer removeFromSuperlayer
             */
        CAShapeLayer * slayer = [CAShapeLayer layer];
        slayer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = [UIColor colorWithHexString:self.lineColor alpha:1-self.lineAlpha].CGColor;
        slayer.lineWidth = _path.lineWidth;
        [self.layer addSublayer:slayer];
        [_path closePath];
        slayer.path = _path.CGPath;
        _slayer = slayer;
        }
//        drawModel =[YXLDrawModel new];
//        drawModel.startPointX=startP.x/self.frame.size.width;
//        drawModel.startPointY=startP.y/self.frame.size.height;
//        drawModel.lineW=self.lineWidth;
//        drawModel.isEraser=self.isErase;
//        drawModel.color=self.lineColor;
//        drawModel.lineAlpha=self.lineAlpha;
//        [self.linesAttribute addObject:drawModel];
    }
}

/**
 *  手势中
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([event allTouches].count > 1){
        return;
    }
    UITouch *touch = [touches anyObject];
    
    pointsArray[2]  =pointsArray[1];
    pointsArray[1]  = [touch previousLocationInView:self];
    pointsArray[0]  = [touch locationInView:self];
    CGPoint mid1    = midPoint(pointsArray[1], pointsArray[2]);
    CGPoint mid2    = midPoint(pointsArray[0], pointsArray[1]);
    if (_isErase) {
        CGMutablePathRef subpath = CGPathCreateMutable();
        CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(subpath, NULL, mid2.x, mid2.y, pointsArray[1].x, pointsArray[1].y);
        CGRect bounds = CGPathGetBoundingBox(subpath);
        CGRect drawBox = bounds;
        drawBox.origin.x        -= self.lineWidth * 1;
        drawBox.origin.y        -= self.lineWidth * 1;
        drawBox.size.width      += self.lineWidth * 2;
        drawBox.size.height     += self.lineWidth * 2;
        UIGraphicsBeginImageContextWithOptions(drawBox.size,NO,0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setNeedsDisplayInRect:drawBox];
    }else{
    [self.path moveToPoint:mid1];
    [self.path addQuadCurveToPoint:mid2 controlPoint:pointsArray[1]];
    _slayer.path = _path.CGPath;
    }
//    YXLMovedModel *model=[YXLMovedModel new];
//    model.moveToPointX=mid1.x/self.frame.size.width;
//    model.moveToPointY=mid1.y/self.frame.size.height;
//    model.curveToPointX=mid2.x/self.frame.size.width;
//    model.curveToPointY=mid2.y/self.frame.size.height;
//    model.controlPointX=pointsArray[1].x/self.frame.size.width;
//    model.controlPointY=pointsArray[1].y/self.frame.size.height;
//    [drawModel.movedPoint addObject:model];
    
}

/**
 *  手势结束
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_endBlock) {
        _endBlock();
    }
    if (!_isErase) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_slayer removeFromSuperlayer];
        [self setNeedsDisplay];
    }
}

/**
 *  取消
 */
- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (_endBlock) {
        _endBlock();
    }
    [_slayer removeFromSuperlayer];
    [self.undoManagerLine undo];

}

-(void)setImage:(UIImage *)image{
    curImage = image;
}

/**
 *  撤销
 */
- (void)undo{
    
    if ([self.undoManagerLine canUndo]) {
        _isErase=NO;
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[self.undoManagerTpme prepareWithInvocationTarget:self] setImage:image];
        [self.undoManagerLine undo];
        [self setNeedsDisplay];
    }
    if (_endBlock) {
        _endBlock();
    }
}
/**
 *  恢复
 */
- (void)redo{
    if ([self.undoManagerTpme canUndo]) {
        _isErase=NO;
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[self.undoManagerLine prepareWithInvocationTarget:self] setImage:image];
        [self.undoManagerTpme undo];
        [self setNeedsDisplay];
    }
    if (_endBlock) {
        _endBlock();
    }
}

-(BOOL)isUndo{
    return [self.undoManagerLine canUndo];
}

-(BOOL)isRedo{
    return [self.undoManagerTpme canUndo];
}

@end
@implementation YXLBezierPath
+ (instancetype)paintPathWithLineWidth:(CGFloat)width
                            startPoint:(CGPoint)startP{
    YXLBezierPath * path = [[self alloc] init];
    path.lineWidth = width;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:startP];
    return path;
}

@end
