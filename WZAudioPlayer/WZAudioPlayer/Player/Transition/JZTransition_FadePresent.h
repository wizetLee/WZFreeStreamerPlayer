//
//  JZTransition_FadePresent.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JZTransitionOrientationType) {
    JZTransitionOrientationType_None                = 0,
    JZTransitionOrientationType_Top,
    JZTransitionOrientationType_Bottom,
    JZTransitionOrientationType_Left,
    JZTransitionOrientationType_Right,
};

@interface JZTransition_FadePresent : NSObject<UIViewControllerAnimatedTransitioning>
{
    JZTransitionOrientationType _orientationType;
}
///方向
@property (nonatomic, assign) JZTransitionOrientationType orientationType;

- (CGPoint)getToVCFrameOrigin;

@end
