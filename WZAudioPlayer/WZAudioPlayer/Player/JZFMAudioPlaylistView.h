//
//  JZFMAudioPlaylistView.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class JZFMAudioListModel;

typedef NS_ENUM(NSUInteger, JZFMAudioPlaylistCellState) {
    JZFMAudioPlaylistCellState_Normal               = 0,    //普通状态  -->未曾播放过
    JZFMAudioPlaylistCellState_Playing,                     //当前播放（蓝色）    -->显示进度
    JZFMAudioPlaylistCellState_Paused,                      //播放暂停状态（蓝色） -->显示已听
    JZFMAudioPlaylistCellState_Played,                      //已经播放过的状态（显示已经）
    JZFMAudioPlaylistCellState_Over,                        //播放完毕（显示灰色）
};

///JZFMAudioListModel
@interface JZFMAudioPlaylistCell : UITableViewCell

@property (nonatomic, assign) JZFMAudioPlaylistCellState state;

- (void)updateIndex:(NSUInteger)index;
- (void)updateWithModel:(JZFMAudioListModel *)model;

@end

@interface JZFMAudioPlaylistCell2 : UITableViewCell
@property (nonatomic, assign) JZFMAudioPlaylistCellState state;
@end


@interface JZFMAudioPlaylistHeader : UIView

@property (nonatomic,   copy) void (^didClickCloseBlock)(void);
@end

@protocol JZFMAudioPlaylistViewProtocol <NSObject>

@optional;
- (void)audioPlaylistViewDidSelectAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface JZFMAudioPlaylistView : UIView

@property (nonatomic,   weak) id<JZFMAudioPlaylistViewProtocol> delegate;

@end


@interface JZFMDetailGuideView : UIView
+ (void)showInView:(UIView *)superView scrolledBlock:(void(^)(CGFloat x))block;

@end

