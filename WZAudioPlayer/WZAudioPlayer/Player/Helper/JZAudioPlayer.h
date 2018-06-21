//
//  JZAudioPlayer.h
//
//
//  Created by liweizhao on 2018/4/20.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JZAudioPlayerItem.h"
@class JZNowPlayingInfoModel;

typedef NS_ENUM(NSUInteger, JZAudioPlayerStatus) {
    JZAudioPlayerStatusIdle                 = 0,
    JZAudioPlayerStatusPlaying,
    JZAudioPlayerStatusPaused,
    JZAudioPlayerStatusStopped,
    JZAudioPlayerStatusFinished,
    JZAudioPlayerStatusError,
};

//
typedef NS_ENUM(NSUInteger, JZAudioPlayerError) {
    JZAudioPlayerErrorUnknown               = 0,
    JZAudioPlayerErrorSource,   
    JZAudioPlayerErrorNetwork,
};

@protocol JZAudioPlayerProtocol <NSObject>

@optional

/**
 音频播放进度
 
 @param timePlayed 当前播放时间
 @param duration 音频总时长
 */
- (void)audioPlayerTimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration;

/**
 返回任务缓存进度
 
 @param totalBytesWritten 已写入数据的量
 @param totalBytesExpectedToWrite 任务总量
 */
- (void)audioPlayerTotalBytesWritten:(int64_t)totalBytesWritten
           totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

///准备播放（设计为：即将开始获取缓存时回调，无关失败与否，主要用于处理UI）
- (void)audioPlayerWillPlay;

///正播放
- (void)audioPlayerPlaying;

///暂停
- (void)audioPlayerPaused;

- (void)audioPlayerStopped;

///播放完毕（预备下一曲）
- (void)audioPlayerPlayedCompleted;

///出错（UI恢复到某个状态）
- (void)audioPlayerOnFailWithError:(JZAudioPlayerError)error;

- (void)audioPlayerNext;

- (void)audioPlayerPrevious;

- (void)audioPlayerSeekToTimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration;



@end

///播放器的通用层封装
@interface JZAudioPlayer : NSObject

/**
 播放逻辑
 缓存逻辑
 播放错误回调
 全局播放队列控制
 播放历史记录（恢复上次播放进度）
 恢复别的App的后台播放
 锁屏逻辑
 播放列表外部维护(此类只负责对单个音频播放，不负责数据的维护)
 不暴露
 **/

@property (nonatomic,   weak) id <JZAudioPlayerProtocol> delegate;

@property (nonatomic, assign, readonly) JZAudioPlayerStatus status;


///播放进度(只有在play状态才能seektime，这个库的问题)
- (void)seekToPosition:(float)position;

///播放速率
- (void)setPlayRate:(float)rate;

///音量
- (void)setVolume:(float)volume;

///开始播放
- (void)playWithItem:(JZAudioPlayerItem *)item;

///暂停播放
- (void)pause;

///恢复暂停播放
- (void)recover;

///终止播放
- (void)stop;

///更新媒体界面显示图层
- (void)setNowPlayingArtWorkWithImage:(UIImage *)cover;
///更新媒体信息
- (void)setNowPlayingInfo:(JZNowPlayingInfoModel *)model;

- (void)setNextTrackCmdEnable:(BOOL)boolean;
- (void)setPreviousTrackCmdEnable:(BOOL)boolean;

///缓存目录路径
+ (NSString *)catalogue;



@end

