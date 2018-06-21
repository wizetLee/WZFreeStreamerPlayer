//
//  JZCircularProgressLayer.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZCircularProgressLayer.h"

@interface JZCircularProgressLayer ()

@property (nonatomic, strong) CAShapeLayer *surfaceLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIBezierPath *renderBezierPath;

@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) CGFloat layerLineWidth;

@end

@implementation JZCircularProgressLayer

@synthesize surfaceStrokeColor = _surfaceStrokeColor;
@synthesize bottomStrokeColor = _bottomStrokeColor;

- (instancetype)initWithCircleRadius:(CGFloat)circleRadius layerLineWidth:(CGFloat)layerLineWidth {
    if (self = [super init]) {
        _circleRadius = circleRadius;
        _layerLineWidth = layerLineWidth;
        self.frame = CGRectZero;
        
        UIBezierPath *tmpBezierPath = [UIBezierPath bezierPath];
        CGFloat circleWH = _circleRadius - _layerLineWidth / 2.0;
        [tmpBezierPath addArcWithCenter:CGPointMake(_circleRadius, _circleRadius)
                                 radius:circleWH
                             startAngle:-M_PI_2
                               endAngle:M_PI_2 * 3.0
                              clockwise:true];
        
        self.bottomLayer.path = tmpBezierPath.CGPath;
        self.surfaceLayer.path = tmpBezierPath.CGPath;
        self.surfaceLayer.mask = self.maskLayer;
        [self addSublayer:self.bottomLayer];
        [self addSublayer:self.surfaceLayer];
        
    }
    return self;
}

//frame 的size 由 _circleRadius 决定
- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, _circleRadius * 2.0, _circleRadius * 2.0)];
}


#pragma mark - Accessor

- (CAShapeLayer *)surfaceLayer {
    if (!_surfaceLayer) {
        _surfaceLayer = [CAShapeLayer layer];
        _surfaceLayer.fillColor = [UIColor clearColor].CGColor;
        _surfaceLayer.strokeColor =[self surfaceStrokeColor].CGColor;
        _surfaceLayer.lineWidth = _layerLineWidth;
        _surfaceLayer.lineCap = @"round";
    }
    return _surfaceLayer;
}


- (CAShapeLayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CAShapeLayer layer];
        _bottomLayer.fillColor = [UIColor clearColor].CGColor;
        _bottomLayer.strokeColor = [self bottomStrokeColor].CGColor;
        _bottomLayer.lineWidth = _layerLineWidth;
        _bottomLayer.lineCap = @"round";
    }
    return _bottomLayer;
}


- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.strokeColor = [UIColor whiteColor].CGColor;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.lineWidth = _layerLineWidth;
        _maskLayer.lineCap = @"round";
    }
    return _maskLayer;
}


- (UIBezierPath *)renderBezierPath {
    if (!_renderBezierPath) {
        _renderBezierPath = [UIBezierPath bezierPath];
    }
    return _renderBezierPath;
}

- (void)setRenderAngle:(double)renderAngle {
    if (renderAngle < 0) {
        renderAngle = 0;
    }
    if (renderAngle > M_PI * 2.0) {
        renderAngle = M_PI * 2.0;
    }
    renderAngle = renderAngle - M_PI_2;
    _renderAngle = renderAngle;
    _progress = _renderAngle / M_PI_2 * 2.0;
    
    CGFloat circleWH =  _circleRadius - _layerLineWidth / 2.0;
    [self.renderBezierPath removeAllPoints];
    [_renderBezierPath addArcWithCenter:CGPointMake(_circleRadius, _circleRadius)
                                 radius:circleWH
                             startAngle:- M_PI_2
                               endAngle:_renderAngle
                              clockwise:1];
    self.maskLayer.path = _renderBezierPath.CGPath;
  
    //可以抛出当前进度所在的点 ： _renderBezierPath.currentPoint
}

-(void)setProgress:(double)progress {
    if (progress > 1.0) {
        progress = 1.0;
    }
    if (progress < 0.0) {
        progress = 0.0;
    }
    //计算
    self.renderAngle = M_PI * 2.0 * progress;

}

- (UIColor *)surfaceStrokeColor {
    if (!_surfaceStrokeColor) {
        _surfaceStrokeColor = [UIColor blueColor];
    }
    return _surfaceStrokeColor;
}

- (UIColor *)bottomStrokeColor {
    if (!_bottomStrokeColor) {
        _bottomStrokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
    return _bottomStrokeColor;
}

- (void)setSurfaceStrokeColor:(UIColor *)surfaceStrokeColor {
    _surfaceStrokeColor = surfaceStrokeColor;
    self.surfaceLayer.strokeColor = _surfaceStrokeColor.CGColor;
    self.renderAngle = _renderAngle;//重渲染以染色
}

- (void)setBottomStrokeColor:(UIColor *)bottomStrokeColor {
    _bottomStrokeColor = bottomStrokeColor;
    self.bottomLayer.strokeColor = _bottomStrokeColor.CGColor;
    self.renderAngle = _renderAngle;//重渲染以染色
}

@end
