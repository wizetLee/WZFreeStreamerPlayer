//
//  JZRemoteCommandManager.h
//   
//
//  Created by liweizhao on 2018/4/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JZNowPlayingInfoModel : NSObject

@property (nonatomic,   copy) NSString *title;                  //标题
@property (nonatomic,   copy) NSString *artist;                 //作者
@property (nonatomic,   copy) NSString *albumTitle;             //相簿名
@property (nonatomic, strong) UIImage *cover;                   //封面
@property (nonatomic, assign) NSUInteger duration;              //音频总时长
@property (nonatomic, assign) NSUInteger playbackTime;          //当前播放时间

@end

@class JZRemoteCommandManager;
@protocol JZRemoteCommandManagerProtocol <NSObject>

///点击播放
- (void)jzRemoteCommand_Play;

///点击暂停
- (void)jzRemoteCommand_Pause;

///点击上一首
- (void)jzRemoteCommand_Previous;

///点击下一首
- (void)jzRemoteCommand_Next;

///拖动到目标时间
- (void)jzRemoteCommand_PositionTime:(NSTimeInterval)time;

///耳机被拔出
- (void)jzRemoteCommand_OldDeviceUnavailable;

///插入了耳机
- (void)jzRemoteCommand_NewDeviceAvailable;

///-------FreeStreamer内部有处理好的中断逻辑，我们只需要处理在其onState处，处理好恢复逻辑即可
///音频开始被中断
- (void)jzRemoteCommand_InterruptionBegin;

///以下两个接口可能不响应，因为需要别的app有调用恢复后台播放的接口
///音频中断恢复
- (void)jzRemoteCommand_InterruptionOptionShouldResume;

///音频中断没有得到恢复
- (void)jzRemoteCommand_InterruptionDoNotResume;

///跳出APP（熄屏）

///回到APP

@end

@interface JZRemoteCommandManager : NSObject

@property (nonatomic,   weak) id<JZRemoteCommandManagerProtocol> delegate;

//要释放此实例，需要手动调用cleanCommand以清理内部的observer
- (void)cleanCommands;
- (void)setNextTrackCmdEnable:(BOOL)boolean;
- (void)setPreviousTrackCmdEnable:(BOOL)boolean;
- (void)setPlayingInfo:(JZNowPlayingInfoModel *)model;
- (void)setPlayingArtWorkWithImage:(UIImage *)cover;
- (void)setPlayingPlayBackTime:(NSUInteger)time duration:(NSUInteger)duration;


+ (void)cleanNowPlayingInfo;
// ----------------------模式配置
///设置后台播放模式
+ (void)setBackgroundPlaybackMode;

///恢复别的APP的播放线路（因为此处时用到了remote control，两次存在冲突，所以线路无法返回）
+ (void)notifyOthersOnDeactivation;



@end
