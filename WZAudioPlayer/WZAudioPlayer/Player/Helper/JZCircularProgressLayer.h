//
//  JZCircularProgressLayer.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *   绘制圆
 *   始终在－PI / 2.0 处绘制   只负责绘制
 */
@interface JZCircularProgressLayer : CALayer

@property (nonatomic, assign) double progress;//范围 0 ~ 1
@property (nonatomic, assign) double renderAngle;//范围 0 ~ M_PI * 2.0
@property (nonatomic, strong) UIColor *surfaceStrokeColor;//进度表层颜色
@property (nonatomic, strong) UIColor *bottomStrokeColor;//进度底层颜色

- (instancetype)initWithCircleRadius:(CGFloat)circleRadius layerLineWidth:(CGFloat)layerLineWidth;



@end
