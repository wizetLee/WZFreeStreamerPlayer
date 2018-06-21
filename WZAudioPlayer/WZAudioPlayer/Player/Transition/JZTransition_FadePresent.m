//
//  JZTransition_FadePresent.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZTransition_FadePresent.h"

@implementation JZTransition_FadePresent

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    _orientationType = JZTransitionOrientationType_None;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    [container addSubview:toVC.view];
    
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGPoint origin = [self getToVCFrameOrigin];
    
    
    //PS：
    toVC.view.frame = CGRectMake(origin.x, origin.y, screenSize.width
                                 , screenSize.height);
    
    toVC.view.alpha = 0.0;
    fromVC.view.alpha = 1.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toVC.view.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height);
        toVC.view.alpha = 1.0;
        
        fromVC.view.alpha = 0.5;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:true];
    }];
}

- (CGPoint)getToVCFrameOrigin {
    
    CGPoint origin = CGPointMake(0.0, 0.0);
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    switch (_orientationType) {
        case JZTransitionOrientationType_None: {
            
        } break;
            
        case JZTransitionOrientationType_Top: {
            origin = CGPointMake(0.0, -screenSize.height);
        } break;
            
        case JZTransitionOrientationType_Bottom: {
            origin = CGPointMake(0.0, screenSize.height);
        } break;
            
        case JZTransitionOrientationType_Left: {
            origin = CGPointMake(-screenSize.width, 0.0);
        } break;
            
        case JZTransitionOrientationType_Right: {
            origin = CGPointMake(screenSize.width, 0.0);
        } break;
            
        default:
            break;
    }
    
    return origin;
}


@end
