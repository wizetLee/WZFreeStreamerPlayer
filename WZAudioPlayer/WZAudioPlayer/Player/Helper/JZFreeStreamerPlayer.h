//
//  JZFreeStreamerPlayer.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/2.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JZAudioController.h"
#import "JZPlaylistItem.h"

@protocol JZFreeStreamerPlayerProtocol<NSObject>
@optional
///------------------------------------普通状态
///获取缓存
- (void)freeStreamerPlayer_AudioStreamBuffering;

///加载完某个文件(缓冲完毕（local or network）)
- (void)freeStreamerPlayer_AudioStreamEndOfFile;

///进入暂停状态
- (void)freeStreamerPlayer_AudioStreamPaused;

///彻底停止播放状态
- (void)freeStreamerPlayer_AudioStreamStopped;

///播放中
- (void)freeStreamerPlayer_AudioStreamPlaying;

///播放完成
- (void)freeStreamerPlayer_AudioStreamPlaybackCompleted;

///------------------------------------数据返回
///轮询的播放进度
- (void)freeStreamerPlayer_AudioStreamIsContinuous:(BOOL)continuous
                                        TimePlayed:(NSUInteger)timePlayed
                                          duration:(NSUInteger)duration;

///轮询的缓存进度 （PS 其实这个进度又是并非是真实的进度，比如在一开是就playformOffset，或者seektime到一些未缓存的地点，那么可能会存在某部分没有被缓存到，所以这个缓存进度并非准确）
- (void)freeStreamerPlayer_AudioStreamIsContinuous:(BOOL)continuous
                                 totalBytesWritten:(int64_t)totalBytesWritten
                         totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;


///------------------------------------出错状态
///warning___不要轻易使用此代理   返回的各种错误（返回若干次），或许是网络出错、或许是url本身存在问题
- (void)freeStreamerPlayer_AudioStreamOnFailWithError:(FSAudioStreamError)error
                                     errorDescription:(NSString *)errorDescription;

///重新连接失败（经历了3次重定向也是失败了，原因；1、url路径文件不存在或者出错 2、网络错误）kFsAudioStreamRetryingFailed时调用
- (void)freeStreamerPlayer_NetworkConnectionError;

@end

///播放器的freeStreamer使用层封装
@interface JZFreeStreamerPlayer : NSObject

@property (nonatomic,   weak) id<JZFreeStreamerPlayerProtocol> delegate;
@property (nonatomic, assign, readonly) FSAudioStreamState state;

- (void)playWithItem:(JZPlaylistItem *)item;
- (void)pause;
- (void)recover;
- (void)stop;

- (void)seekToPosition:(float)position;
- (void)setPlayRate:(float)rate;
- (void)setVolume:(float)volume;
- (void)setCacheCatalogue:(NSString *)catalogue;

@end
