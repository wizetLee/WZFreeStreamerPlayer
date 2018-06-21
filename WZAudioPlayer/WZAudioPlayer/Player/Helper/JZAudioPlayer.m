    //
//  JZAudioPlayer.m
//
//
//  Created by liweizhao on 2018/4/20.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZAudioPlayer.h"
#import "JZFreeStreamerPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface JZAudioPlayer()<JZRemoteCommandManagerProtocol, JZFreeStreamerPlayerProtocol>

///播放器
@property (nonatomic, strong) JZFreeStreamerPlayer *player;

///多媒体界面控制器
@property (nonatomic, strong) JZRemoteCommandManager *commandManager;

@property (nonatomic, strong) JZNowPlayingInfoModel *model;
@property (nonatomic, assign) JZAudioPlayerStatus status;

@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) NSURL *coverURL;


@end

@implementation JZAudioPlayer

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

#pragma mark - Private Methods
- (void)defaultConfig {
    
    _commandManager = [[JZRemoteCommandManager alloc] init];
    _commandManager.delegate = self;
    
    [self setupPlayer];
}

- (void)setupPlayer {
    
    _player = [[JZFreeStreamerPlayer alloc] init];
    _player.delegate = self;
    [_player setCacheCatalogue:[self.class catalogue]];
    
}

- (void)requsetCoverWithURL:(NSURL *)url {
    if (_coverURL && url && [_coverURL.absoluteString isEqualToString: url.absoluteString]) {
        if (_cover) {
           [self setNowPlayingArtWorkWithImage:_cover];
        }
        return;
    }
    
    _coverURL = url;
    _cover = nil;
    [self setNowPlayingArtWorkWithImage:nil];
    
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            _cover = image;
        }
    }];
}

#pragma mark - Public Methods

///获取缓存目录
+ (NSString *)catalogue {
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cataloguePath = [docPath stringByAppendingPathComponent:@"JZAudioPlayerCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cataloguePath]) {
        NSError *error = nil;
        [manager createDirectoryAtPath:cataloguePath withIntermediateDirectories:true attributes:nil error:&error];
        if (error) {
            cataloguePath = docPath;
        }
    }
    
    return cataloguePath;
}

///seek position
- (void)seekToPosition:(float)position {
    
    if (position < 0) { position = 0; }
    if (position > 1) { position = 1; }
    
    [_player seekToPosition:position];
}

///修改音量
- (void)setVolume:(float)volume {
    
    if (volume < 0) { volume = 0; };
    if (volume > 1) { volume = 1; };
    
    [_player setVolume:volume];
    
}


- (void)setPlayRate:(float)rate {
    
    [_player setPlayRate:rate];
    
}

///更新媒体界面显示图层
- (void)setNowPlayingArtWorkWithImage:(UIImage *)cover {
    [_commandManager setPlayingArtWorkWithImage:cover];
}

///更新媒体信息
- (void)setNowPlayingInfo:(JZNowPlayingInfoModel *)model {
    [_commandManager setPlayingInfo:model];
}
- (void)setNextTrackCmdEnable:(BOOL)boolean {
    [_commandManager setNextTrackCmdEnable:boolean];
}
- (void)setPreviousTrackCmdEnable:(BOOL)boolean {
    [_commandManager setPreviousTrackCmdEnable:boolean];
}

///开始播放
- (void)playWithItem:(JZAudioPlayerItem *)item {
    
    [JZRemoteCommandManager setBackgroundPlaybackMode];
    
    ///模型转换
    JZPlaylistItem *plItem = JZPlaylistItem.alloc.init;
    plItem.url          = item.url;
    plItem.title        = item.title;
    plItem.infoModel.title              = item.title;
    plItem.infoModel.artist             = item.artist;
    plItem.infoModel.albumTitle         = item.albumTitle;
    plItem.infoModel.cover              = item.cover;
    plItem.infoModel.duration           = item.duration;
    plItem.infoModel.playbackTime       = item.playbackTime;
    
    _model = plItem.infoModel;
    [self requsetCoverWithURL:item.coverURL];
    
    [self setNowPlayingInfo:_model];
    [_commandManager setPlayingPlayBackTime:item.playbackTime duration:item.duration];
  
  
    ///专门设计用于处理UI
    if ([_delegate respondsToSelector:@selector(audioPlayerWillPlay)]) {
        [_delegate audioPlayerWillPlay];
    }
    
    //配置对应的信息
    [_player playWithItem:plItem];
}

///暂停播放
- (void)pause {
    [_player pause];
}

///恢复暂停播放
- (void)recover {
    [_player recover];
}

///终止播放
- (void)stop {
    [_player stop];
//    [_commandManager cleanCommands];
}

#pragma mark -  JZRemoteCommandManagerProtocol
///开始中断
- (void)jzRemoteCommand_InterruptionBegin {
    [self pause];
}

///中断了不恢复
- (void)jzRemoteCommand_InterruptionDoNotResume {
}

///中断了准备恢复
- (void)jzRemoteCommand_InterruptionOptionShouldResume {
}

- (void)jzRemoteCommand_Next {
    
    if ([_delegate respondsToSelector:@selector(audioPlayerNext)]) {
        [_delegate audioPlayerNext];
    }
    
}

- (void)jzRemoteCommand_Previous {
    
    if ([_delegate respondsToSelector:@selector(audioPlayerPrevious)]) {
        [_delegate audioPlayerPrevious];
    }
    
}


///耳机被拔出
- (void)jzRemoteCommand_OldDeviceUnavailable {
    [self pause];
}


///插入了耳机 （保留原状态 or 开始播放）
- (void)jzRemoteCommand_NewDeviceAvailable {
    ///保持原有状态即可
}

///点击了暂停按钮
- (void)jzRemoteCommand_Pause {
    [self pause];
}

///点击了播放按钮
- (void)jzRemoteCommand_Play {
    [self recover];
}

//移动到某个点
- (void)jzRemoteCommand_PositionTime:(NSTimeInterval)time {
    if (_model.duration) {
        CGFloat position =  time * 1.0 / _model.duration;
        if (position > 0.99) {
            position = 0.99;
            time = position * _model.duration;
        }
        if (_model.duration - time < 1) {
            time = _model.duration - 1;
            position = (time * 1.0 / _model.duration);
        }
        
        _model.playbackTime = time;
       
        if (self.status != JZAudioPlayerStatusPlaying) {
            [self recover];
        }
        
        [self seekToPosition:position];
        [self freeStreamerPlayer_AudioStreamIsContinuous:false TimePlayed:time duration:_model.duration];
       
        if ([_delegate respondsToSelector:@selector(audioPlayerSeekToTimePlayed:duration:)]) {
            [_delegate audioPlayerSeekToTimePlayed:time duration:_model.duration];
        }
    }
}


#pragma mark - JZFreeStreamerPlayerProtocol

///获取缓存
- (void)freeStreamerPlayer_AudioStreamBuffering {
    
}

///加载完某个文件(缓冲完毕（local or network）)
- (void)freeStreamerPlayer_AudioStreamEndOfFile {

}

///进入暂停状态
- (void)freeStreamerPlayer_AudioStreamPaused {
    _status = JZAudioPlayerStatusPaused;
    if ([_delegate respondsToSelector:@selector(audioPlayerPaused)]) {
        [_delegate audioPlayerPaused];
    }
}

///彻底停止播放状态
- (void)freeStreamerPlayer_AudioStreamStopped {
    _status = JZAudioPlayerStatusStopped;
    if ([_delegate respondsToSelector:@selector(audioPlayerStopped)]) {
        [_delegate audioPlayerStopped];
    }
}

///播放中
- (void)freeStreamerPlayer_AudioStreamPlaying {
    //更新锁屏信息
    [self setNowPlayingInfo:_model];
    
    _status = JZAudioPlayerStatusPlaying;
    if ([_delegate respondsToSelector:@selector(audioPlayerPlaying)]) {
        [_delegate audioPlayerPlaying];
    }
}

///播放完成
- (void)freeStreamerPlayer_AudioStreamPlaybackCompleted {
    _status = JZAudioPlayerStatusFinished;
    if ([_delegate respondsToSelector:@selector(audioPlayerPlayedCompleted)]) {
        [_delegate audioPlayerPlayedCompleted];
    }
    
    ///播放时间矫正
    [self freeStreamerPlayer_AudioStreamIsContinuous:false TimePlayed:_model.duration duration:_model.duration];
}


///------------------------------------数据返回
- (void)freeStreamerPlayer_AudioStreamIsContinuous:(BOOL)continuous TimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration {

    ///更新媒体界面上的时间 图像
    [self requsetCoverWithURL:self.coverURL];
    [_commandManager setPlayingPlayBackTime:timePlayed duration:duration];
    if ([_delegate respondsToSelector:@selector(audioPlayerTimePlayed:duration:)]) {
        [_delegate audioPlayerTimePlayed:timePlayed duration:duration];
    }
}

- (void)freeStreamerPlayer_AudioStreamIsContinuous:(BOOL)continuous totalBytesWritten:(int64_t)totalBytesWritten
                         totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    if ([_delegate respondsToSelector:@selector(audioPlayerTotalBytesWritten:totalBytesExpectedToWrite:)]) {
        [_delegate audioPlayerTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    
}

///------------------------------------出错状态
///warning___不要轻易使用此代理   返回的各种错误（返回若干次），或许是网络出错、或许是url本身存在问题
- (void)freeStreamerPlayer_AudioStreamOnFailWithError:(FSAudioStreamError)error errorDescription:(NSString *)errorDescription {
}

///重新连接失败（经历了3次重定向也是失败了，原因；1、url路径文件不存在或者出错 2、网络错误）kFsAudioStreamRetryingFailed时调用
- (void)freeStreamerPlayer_NetworkConnectionError {
    _status = JZAudioPlayerStatusError;
    if ([_delegate respondsToSelector:@selector(audioPlayerOnFailWithError:)]) {
        [_delegate audioPlayerOnFailWithError:JZAudioPlayerErrorNetwork];
    }
    
}


@end

