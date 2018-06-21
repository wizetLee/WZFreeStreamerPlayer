//
//  JZRemoteCommandManager.m
//   
//
//  Created by liweizhao on 2018/4/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZRemoteCommandManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation JZNowPlayingInfoModel

@end

@interface JZRemoteCommandManager()
{
    MPRemoteCommandCenter __weak *rcc;
}

@property (nonatomic, strong) id playTarget;
@property (nonatomic, strong) id pauseTarget;
@property (nonatomic, strong) id nextTrackTarget;
@property (nonatomic, strong) id previousTrackTarget;
@property (nonatomic, strong) id changePlaybackPositionTarget;

@property (nonatomic, strong) MPRemoteCommand *nextTrackCmd;
@property (nonatomic, strong) MPRemoteCommand *previousTrackCmd;

@property (nonatomic,   weak) MPNowPlayingInfoCenter *nowPlayingInfoCenter;
@property (nonatomic, strong) NSMutableDictionary *nowPlayingInfo;

@end

@implementation JZRemoteCommandManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self defaultConfig];
        [self addNotifications];
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self cleanCommands];
    [self removeNotifications];
}

///清理控制事件
- (void)cleanCommands {
    [rcc.playCommand removeTarget:_playTarget];
    [rcc.pauseCommand removeTarget:_pauseTarget];
    [rcc.previousTrackCommand removeTarget:_previousTrackTarget];
    [rcc.nextTrackCommand removeTarget:_nextTrackTarget];
    
    if (@available(iOS 9.1, *)) {
        [rcc.changePlaybackPositionCommand removeTarget:_changePlaybackPositionTarget];
    }

    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)setNextTrackCmdEnable:(BOOL)boolean {
    _nextTrackCmd.enabled = boolean;
}

- (void)setPreviousTrackCmdEnable:(BOOL)boolean {
    _previousTrackCmd.enabled = boolean;
}

///构建控制事件
- (void)defaultConfig {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //媒体控制中心
    rcc = [MPRemoteCommandCenter sharedCommandCenter];//iOS 7.1
    
    __weak typeof(self) weakSelf = self;
    //播放
    MPRemoteCommand *playCmd = rcc.playCommand;
    playCmd.enabled = true;
    ///warning  这些配置的内部存在相互引用
    _playTarget = [playCmd addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([weakSelf.delegate respondsToSelector:@selector(jzRemoteCommand_Play)]) {
            [weakSelf.delegate  jzRemoteCommand_Play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //暂停
    MPRemoteCommand *pauseCmd = rcc.pauseCommand;
    pauseCmd.enabled = true;
    _pauseTarget = [pauseCmd addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([weakSelf.delegate respondsToSelector:@selector(jzRemoteCommand_Pause)]) {
            [weakSelf.delegate jzRemoteCommand_Pause];
        }
         return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //下一曲
    MPRemoteCommand *nextTrackCmd = rcc.nextTrackCommand;
    nextTrackCmd.enabled = true;
    _nextTrackTarget = [nextTrackCmd addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([weakSelf.delegate respondsToSelector:@selector(jzRemoteCommand_Next)]) {
            [weakSelf.delegate jzRemoteCommand_Next];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    _nextTrackCmd = nextTrackCmd;
    
    //上一曲
    MPRemoteCommand *previousTrackCmd = rcc.previousTrackCommand;
    previousTrackCmd.enabled = true;
    _previousTrackTarget = [previousTrackCmd addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([weakSelf.delegate respondsToSelector:@selector(jzRemoteCommand_Previous)]) {
            [weakSelf.delegate  jzRemoteCommand_Previous];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    _previousTrackCmd = previousTrackCmd;
    
    
    //拖动播放位置 -- iOS 9.1
    if (@available(iOS 9.1, *)) {
        MPChangePlaybackPositionCommand *changePlaybackPositionCmd = rcc.changePlaybackPositionCommand;
        changePlaybackPositionCmd.enabled = true;
       _changePlaybackPositionTarget =  [changePlaybackPositionCmd addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
           MPChangePlaybackPositionCommandEvent *playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
           if ([weakSelf.delegate respondsToSelector:@selector(jzRemoteCommand_PositionTime:)]) {
               [weakSelf.delegate jzRemoteCommand_PositionTime:playbackPositionEvent.positionTime];
           }
           return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    
    _nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    _nowPlayingInfo = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
}

#pragma mark - 设置显示的信息

- (void)setPlayingPlayBackTime:(NSUInteger)time duration:(NSUInteger)duration {
    _nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(time);
    _nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(duration);
    _nowPlayingInfoCenter.nowPlayingInfo = _nowPlayingInfo;
}

- (void)setPlayingArtWorkWithImage:(UIImage *)cover {
    _nowPlayingInfo[MPMediaItemPropertyArtwork] = [self.class artworkWithImage:cover];
    _nowPlayingInfoCenter.nowPlayingInfo = _nowPlayingInfo;
}


- (void)setPlayingInfo:(JZNowPlayingInfoModel *)model {
    if (model == nil) {
        [self.class cleanNowPlayingInfo];
        return;
    }
    NSMutableDictionary *info = _nowPlayingInfo;
    
    info[MPMediaItemPropertyTitle] = model.title;
    
    info[MPMediaItemPropertyArtist] = model.artist;
    
    info[MPMediaItemPropertyAlbumTitle] = model.albumTitle;
    
    ///需要注意的情况是，图片的下载时间比我们切换歌曲的时间慢，那么就需要取消前一个请求图片的请求，保证图片显示正确
    UIImage *cover = model.cover;//cache -> disk -> newwork
    if (cover) {
        info[MPMediaItemPropertyArtwork] = [self.class artworkWithImage:cover];;
    }
    
    //当前播放时长
    NSUInteger playbackTime = model.playbackTime;
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(playbackTime);
    
    //播放总时长
    NSUInteger duration = model.duration;
    info[MPMediaItemPropertyPlaybackDuration] = @(duration);
    _nowPlayingInfoCenter.nowPlayingInfo = info;
}


+ (void)cleanNowPlayingInfo  {
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
}


+ (MPMediaItemArtwork *)artworkWithImage:(UIImage *)cover {
    MPMediaItemArtwork *artwork = nil;
    if (cover) {
        if (@available(iOS 10.0, *)) {
            artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:cover.size requestHandler:^UIImage * _Nonnull(CGSize size) {
                return cover;
            }];
        } else {
            artwork = [[MPMediaItemArtwork alloc] initWithImage:cover];
        }
    }
    return artwork;
}

#pragma mark - 通知处理
///添加必要的通知
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    //音频被中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    
    
    //耳机插入 拔出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];

}
///移除通知
- (void)removeNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)willResignActiveNotification:(NSNotification *)notification {

}


- (void)didBecomeActiveNotification:(NSNotification *)notification {

}

///设置中断处理
- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
                                           
   if (type == AVAudioSessionInterruptionTypeBegan) {
       //Handle InterruptionBegan
       //开始中断
       if ([self.delegate respondsToSelector:@selector(jzRemoteCommand_InterruptionBegin)]) {
           [self.delegate jzRemoteCommand_InterruptionBegin];
       }
   } else {
       AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
       if (options == AVAudioSessionInterruptionOptionShouldResume) {

           if ([self.delegate respondsToSelector:@selector(jzRemoteCommand_InterruptionOptionShouldResume)]) {
               [self.delegate jzRemoteCommand_InterruptionOptionShouldResume];
           }
       } else {
           NSLog(@"中断没有得到恢复，处理好UI的逻辑");
           if ([self.delegate respondsToSelector:@selector(jzRemoteCommand_InterruptionDoNotResume)]) {
               [self.delegate jzRemoteCommand_InterruptionDoNotResume];
           }
       }
   }
}

///线路修改
- (void)audioSessionRouteChangeNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSInteger reason = [[info valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (reason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
                NSLog(@"耳机插入，考虑是否要恢复音乐");
                if ([_delegate respondsToSelector:@selector(jzRemoteCommand_NewDeviceAvailable)]) {
                    [_delegate jzRemoteCommand_NewDeviceAvailable];
                } break;
                
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                NSLog(@"耳机拔出，播放操作");
                if ([_delegate respondsToSelector:@selector(jzRemoteCommand_OldDeviceUnavailable)]) {
                    [_delegate jzRemoteCommand_OldDeviceUnavailable];
                } break;
                
            default: {
                
            } break;
        }
        
    });
}

#pragma mark - 静态方法
///设置后台播放模式
+ (void)setBackgroundPlaybackMode {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.category != AVAudioSessionCategoryPlayback) {
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
        [session setActive:true error:nil];
    }
}

///恢复别的APP的播放线路（因为此处时用到了remote control，两者存在冲突，所以线路无法返回）
+ (void)notifyOthersOnDeactivation {
    [[AVAudioSession sharedInstance] setActive:false withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
