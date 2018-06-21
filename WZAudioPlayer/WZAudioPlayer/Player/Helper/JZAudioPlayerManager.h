//
//  JZAudioPlayerManager.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/8.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JZAudioPlayer.h"
#import "JZFMAudioListModel.h"


@protocol JZAudioPlayerManagerProtocol<JZAudioPlayerProtocol>

@optional
///通知消费者 播放顺序的情况
- (void)audioPlayerWillPlayNewAlbum;

@end

@interface JZAudioPlayerManager : NSObject <JZAudioPlayerProtocol>
/*
 1、管理播放队列
 2、负责播放情况的推送（广播, 生产-消费）
 3、播放历史的捕捉、记录
 4、注意播放出错的类型（1、网络原因 2、资源本身的原因 3、...）
 */


@property (nonatomic, strong, readonly) NSMutableArray <JZFMAudioListModel *>*playlist;  

@property (nonatomic, assign, readonly) JZAudioPlayerStatus status; //播放器状态

@property (nonatomic, assign, readonly) NSUInteger timePlayed;  //当前播放进度
@property (nonatomic, assign, readonly) NSUInteger duration;    //当前音频总时长



+ (instancetype)sharedInstance;

- (void)seekToPosition:(float)position;     //PS 只允许在播放中的状态修改播放的位置
- (void)setVolume:(float)volume;

- (void)setPlaylist:(NSArray <JZFMAudioListModel *>*)playlist;
- (void)playWithIndex:(NSUInteger)index;


- (void)pause;
- (void)recover;
- (void)stop;

- (void)next;
- (void)previous;
- (BOOL)hasNextItem;
- (BOOL)hasPreviousItem;

- (NSUInteger)curItemIndex;
- (JZFMAudioListModel *)curItem;


//弱引用数组 无需手动移除消费者
- (void)appendCustomer:(id<JZAudioPlayerManagerProtocol>)customer;


@end
