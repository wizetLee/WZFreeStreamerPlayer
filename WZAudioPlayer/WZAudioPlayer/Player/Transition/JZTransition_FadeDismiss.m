//
//  JZTransition_FadeDismiss.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZTransition_FadeDismiss.h"

@implementation JZTransition_FadeDismiss



- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGSize screenSize = UIScreen.mainScreen.bounds.size;

    
    ///
    CGPoint origin = [self getToVCFrameOrigin];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toVC.view.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height);
        toVC.view.alpha = 1.0;
        
        ///fade
        fromVC.view.frame = CGRectMake(origin.x, origin.y, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
        fromVC.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        CGRect frame = fromVC.view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        
        [transitionContext completeTransition:true];
    }];
    
}



@end
