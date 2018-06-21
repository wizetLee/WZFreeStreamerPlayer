//
//  JZFMDretailAudioPlayerContentView.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/3.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZFMAudioListModel;
@protocol JZFMDretailAudioPlayerContentViewProtocol <NSObject>

@optional
- (void)audioPlayerContentViewClickedPathButton;

@end

@interface JZFMDretailAudioPlayerContentView : UIView

@property (nonatomic,   weak) id<JZFMDretailAudioPlayerContentViewProtocol> delegate;


//配置一个正在等待的状态
- (void)disable:(BOOL)boolean;

///更新跑马等的数据

///更新tableView(设置数据)
- (void)updateTableViewWithArray:(NSArray <JZFMAudioListModel *> *)array;

///选中table中的数据

///动画
- (void)addAnimation;
- (void)pauseAnimation;
- (void)recoverAnimation;
- (void)removeAnimation;

- (void)updateTitle:(NSString *)title;
- (void)updateCoverWithURL:(NSURL *)url;
- (void)showPlayStatus:(BOOL)boolean;
- (void)scrollToX:(CGFloat)x;

@end
