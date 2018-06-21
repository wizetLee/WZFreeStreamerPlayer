//
//  JZFMDretailAudioPlayerControlView.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/3.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZFMAlbumDetailModel;

@interface JZFMDetailAudioPlayerControlItemView : UIView

@end



@protocol JZFMDretailAudioPlayerControlViewProtocol <NSObject>

- (void)audioPlayerControlViewClickedItemInIndex:(NSUInteger)index;
- (void)audioPlayerControlViewClickedPlayBtn;
- (void)audioPlayerControlViewClickedPauseBtn;
- (void)audioPlayerControlViewClickedPreviousBtn;
- (void)audioPlayerControlViewClickedNextBtn;
- (void)audioPlayerControlViewProgressValueChange:(float)value dragging:(BOOL)dragging;


@end

///音频控制器
@interface JZFMDretailAudioPlayerControlView : UIView

@property (nonatomic,   weak) id<JZFMDretailAudioPlayerControlViewProtocol> delegate;



//配置一个正在等待的状态
- (void)disable:(BOOL)boolean;

///开放播放和暂停的接口
- (void)showPlayStatus:(BOOL)boolean;
- (void)hasPreviousItem:(BOOL)boolean;
- (void)hasNextItem:(BOOL)boolean;
- (void)updatePlayListWithSum:(NSUInteger)sum curIndex:(NSUInteger)index;

- (void)leftTitle:(NSString *)title;
- (void)rightTitle:(NSString *)title;
- (void)updateProgress:(float)progress;
- (void)updatePreloadProgress:(float)progress;
@end
