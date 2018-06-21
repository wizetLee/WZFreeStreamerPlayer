//
//  JZFreeStreamerPlayer.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/2.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//


#import "JZFreeStreamerPlayer.h"
#import "WZToast.h"

@interface JZFreeStreamerPlayer()

@property (nonatomic, strong) JZPlaylistItem *selectedPlaylistItem;
@property (nonatomic, strong) JZAudioController *audioController;
@property (nonatomic, strong) NSTimer *progressUpdateTimer;     //当前item播放进度
@property (nonatomic, strong) NSTimer *prebufferTimer;          //当前item预加载进度

///记录被中断的记录
@property (nonatomic, assign) BOOL interrupted;//是否被中断？
@property (nonatomic, assign) FSSeekByteOffset interruptedOffset;///被中断的偏移量保存
//拷贝active中的state用于检查
@property (nonatomic, assign) FSAudioStreamState state;

@property (nonatomic, assign) BOOL activePause;

@end

@implementation JZFreeStreamerPlayer

#pragma mark - life cycle
- (void)dealloc {
    [self cleanTimer:_progressUpdateTimer];
    [self cleanTimer:_prebufferTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
    
}

#pragma mark - Private Methods
- (void)defaultConfig {
    
    _audioController = [[JZAudioController alloc] init];
    _audioController.configuration = [self.class standerdConfiguration];
    
    //基本配置部分
    __weak typeof(self) weakSelf = self;
    //出错了
    _audioController.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
        //抛出错误 UI全部处理为准备播放的状态 （此处错误可能会返回若干次）
        if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamOnFailWithError:errorDescription:)]) {
            [weakSelf.delegate freeStreamerPlayer_AudioStreamOnFailWithError:error errorDescription:errorDescription];
        }
        
        //network error 重新连接失败
        if (error == kFsAudioStreamErrorNetwork) {
        
            ///一次原始调用+三次重新定向的错误， 产生4次回调
            if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_NetworkConnectionError)]) {
                [weakSelf.delegate freeStreamerPlayer_NetworkConnectionError];
            }
        }
    };
    
    //状态返回
    _audioController.onStateChange = ^(FSAudioStreamState state) {
        weakSelf.state = state;//拷贝用于检查
        switch (state) {
            case kFsAudioStreamRetrievingURL: {
                //检索URL合法性
                NSLog(@"############检索URL合法性");
                
            } break;
                
            case kFsAudioStreamStopped: {
                //已停止 --可能需要重新播放
                NSLog(@"############已停止播放");
                //清空所有计时器
                [weakSelf cleanTimer:weakSelf.prebufferTimer];
                [weakSelf cleanTimer:weakSelf.progressUpdateTimer];
                
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamStopped)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamStopped];
                }
                
            } break;
                
            case kFsAudioStreamBuffering: {
                //缓存中
                NSLog(@"############获取缓存中");
                //存在缓存 这是info
                //重新填充信息
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamBuffering)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamBuffering];
                }
              
            } break;
                
            case kFsAudioStreamPlaying: {
                NSLog(@"############播放中");
                 if (!weakSelf.activePause) {
                     [weakSelf setupTimers];
                     if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamPlaying)]) {
                         [weakSelf.delegate freeStreamerPlayer_AudioStreamPlaying];
                     }
                 }
              
            } break;
                
            case kFsAudioStreamPaused: {
                //暂停
                NSLog(@"############暂停中");
           
                [weakSelf cleanTimer:weakSelf.progressUpdateTimer];
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamPaused)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamPaused];
                }
              
            } break;
                
            case kFsAudioStreamSeeking: {
                //seeking time now
                NSLog(@"############seeking time");
            } break;
                
            case kFSAudioStreamEndOfFile: {
                //已加载完成某个文件(缓冲完毕)
                NSLog(@"############加载完成某个文件(缓冲完毕（local or network）)");
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamEndOfFile)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamEndOfFile];
                }
            } break;
                
            case kFsAudioStreamFailed: {
                //解析流失败
                NSLog(@"############解析流失败");
                ///清空所有计时器
                [weakSelf cleanTimer:weakSelf.prebufferTimer];
                [weakSelf cleanTimer:weakSelf.progressUpdateTimer];
                
            } break;
                
            case kFsAudioStreamRetryingStarted: {
                //http断开了，正在尝试重新连接
                NSLog(@"############http断开了，正在尝试重新连接");
                
            } break;
                
            case kFsAudioStreamRetryingSucceeded: {
                //http重连成功
                NSLog(@"############http重连成功");
            } break;
                
            case kFsAudioStreamRetryingFailed: {
                //http重连失败
                ///这里返回的重链接失败
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_NetworkConnectionError)]) {
                    [weakSelf.delegate freeStreamerPlayer_NetworkConnectionError];
                    NSLog(@"############http重连失败，url出错或网络连接失败出错");
                }
            } break;
                
            case kFsAudioStreamPlaybackCompleted: {
                //播放完成
                NSLog(@"############播放完成");
                [weakSelf cleanTimer:weakSelf.prebufferTimer];
                [weakSelf cleanTimer:weakSelf.progressUpdateTimer];
                ///人工配置 播放完毕时间的回调
                FSStreamPosition end = weakSelf.audioController.activeStream.duration;
                NSUInteger duration = end.minute * 60 + end.second;
                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamIsContinuous:TimePlayed:duration:)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamIsContinuous:false TimePlayed:duration duration:duration];
                }
                

                if ([weakSelf.delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamPlaybackCompleted)]) {
                    [weakSelf.delegate freeStreamerPlayer_AudioStreamPlaybackCompleted];
                }
            } break;
                
            default: {
                NSLog(@"_________________________未知状态___________________");
            } break;
                
        }
    };
}

///清理timer
- (void)cleanTimer:(NSTimer *)timer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

///设置timer
- (NSTimer *)setupTimerWithTimeInterval:(float)timeInterval withSEL:(SEL)sel {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:sel userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

- (void)setupTimers {
    //检查这个文件是否需要下载？继续下载？（FreeStraemer无继续下载的接口）
    
    //缓存条计时器
    [self cleanTimer:_prebufferTimer];
    _prebufferTimer = [self setupTimerWithTimeInterval:0.5 withSEL:@selector(updatePrebufferProgress:)];
    [_prebufferTimer fire];
    
    ///播放进度计时器
    [self cleanTimer:_progressUpdateTimer];
    _progressUpdateTimer = [self setupTimerWithTimeInterval:0.5 withSEL:@selector(updatePlaybackProgress:)];
    [_progressUpdateTimer fire];
    
}


#pragma mark - Public Methods
- (void)setCacheCatalogue:(NSString *)catalogue {
    _audioController.configuration.cacheDirectory = catalogue;
}

+ (FSStreamConfiguration *)standerdConfiguration {
    
    FSStreamConfiguration *config = [[FSStreamConfiguration alloc] init];
    //自定义目录
    config.cacheDirectory = [self catalogue];
    
    return config;
}

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
    
    FSStreamPosition pos;
    pos.minute = 0;
    pos.second = 0;
    pos.position = position;
    
    [_audioController.activeStream seekToPosition:pos];

}

///修改音量
- (void)setVolume:(float)volume {
    
    if (volume < 0) { volume = 0; };
    if (volume > 1) { volume = 1; };
    [_audioController setVolume:volume];
    
}

///设置播放速率
- (void)setPlayRate:(float)rate {
    //_audioController.configuration.enableTimeAndPitchConversion = true时才能使用
    [_audioController.activeStream setPlayRate:rate];
}


- (void)playWithItem:(JZPlaylistItem *)item {
    _activePause = false;
    
    if (![item isKindOfClass:JZPlaylistItem.class]) return;
    
    _selectedPlaylistItem = nil;
    NSURL *url = item.url ?: item.originatingUrl;
    [WZToast toastWithContent:item.title];
    NSAssert(url, @"链接缺失");
    
    _selectedPlaylistItem = item;
    
    if (!_audioController) {
        [self defaultConfig];
    }
    
    _audioController.url = url;
    [_audioController play];
    
}

- (void)pause {
    if (_state == kFsAudioStreamPlaying) {
        _activePause = true;
        [_audioController pause];
    }
}

- (void)recover {
    _activePause = false;
    if (_state == kFsAudioStreamPaused) {
        [_audioController pause];
    } else if (_state == kFsAudioStreamPlaying) {
        ///为了处理：未缓存完-》手动拖动播放位置（seektime-〉暂停播放）-〉缓存完毕时状态变成kFsAudioStreamPlaying的bug
        ///感觉要炸了
        [_audioController pause];
        [_audioController pause];
        [_audioController pause];
        dispatch_async(dispatch_get_main_queue(), ^{
          
        });
        
    } else {
        ///重新播放
        [self playWithItem:_selectedPlaylistItem];
    }
    
}

- (void)stop {
    _activePause = false;
    [_audioController stop];
    _audioController = nil;
}

#pragma mark - timer action
///更新缓存进度
- (void)updatePrebufferProgress:(NSTimer *)timer {
    
    if (_audioController.activeStream.continuous) {
        NSLog(@"####这是个直播流 %s", __func__);
    } else {
        
        FSSeekByteOffset currentOffset = _audioController.activeStream.currentSeekByteOffset;
        
        UInt64 contentLength = _audioController.activeStream.contentLength;
        
        if (contentLength > 0) {
            
            UInt64 totalBufferedData = currentOffset.start + _audioController.activeStream.prebufferedByteCount;
            
#warning 这个缓存的取巧做的缓存进度。。。(如果做过seektime操作，那么这个缓存进度就是错误的)(仿照官方demo)
            UInt64 totalBufferedData_f = totalBufferedData;
            UInt64 contentLength_f = _audioController.activeStream.contentLength;
            
            float bufferedDataFromTotal = totalBufferedData_f / contentLength_f;
            
            if (bufferedDataFromTotal >= 1.0) {
                
                bufferedDataFromTotal = 1.0;
            }
            
            if ([_delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamIsContinuous:totalBytesWritten:totalBytesExpectedToWrite:)]) {
                [_delegate freeStreamerPlayer_AudioStreamIsContinuous:false totalBytesWritten:totalBufferedData_f totalBytesExpectedToWrite:contentLength_f];
            }
            
            if (bufferedDataFromTotal >= 1.0) {
                [self cleanTimer:_prebufferTimer];
            }
        }
    }
}

///更新播放进度
- (void)updatePlaybackProgress:(NSTimer *)timer {
    
    if (_audioController.activeStream.continuous) {
        ///别的处理模式
        NSLog(@"####这是个直播流 %s", __func__);
    } else {
        ///PS 并没有直接暴露时间方面的接口，导致需要二次转换，如果有此需求可以，可以直接修改源码
        ///当前播放位置的时分
        FSStreamPosition cur = _audioController.activeStream.currentTimePlayed;
        ///音频总长度的时分
        FSStreamPosition end = _audioController.activeStream.duration;
        
        NSUInteger curTimePlayed     = cur.minute * 60 + cur.second;
        NSUInteger duration         = end.minute * 60 + end.second;
        
        if (curTimePlayed > duration) {
            [self cleanTimer:_progressUpdateTimer];
        }
        if ([_delegate respondsToSelector:@selector(freeStreamerPlayer_AudioStreamIsContinuous:TimePlayed:duration:)]) {
            [_delegate freeStreamerPlayer_AudioStreamIsContinuous:false TimePlayed:curTimePlayed duration:duration];
        }
    }
}



@end
