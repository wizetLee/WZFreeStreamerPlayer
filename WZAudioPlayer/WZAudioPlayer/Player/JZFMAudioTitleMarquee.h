//
//  JZFMAudioTitleMarquee.h
//
//
//  Created by liweizhao on 2018/4/28.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 只按照需求而做的跑马灯：
 没啥可拓展性
 向左跑
 单个数据不断地循环
 
 */
@interface JZFMAudioTitleMarquee : UIView

//@property (nonatomic,   copy) NSArray <NSString *>*dataSource;   //暂只支持字符串

@property (nonatomic,   copy,  readonly) NSString *title;

///重布局
- (void)updateWithTitle:(NSString *)title;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)run;

- (void)pause;

- (void)stop;
@end
