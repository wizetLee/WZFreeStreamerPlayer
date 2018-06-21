//
//  JZAudioPlayerManager.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/8.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZAudioPlayerManager.h"
//#import "JZFMVCDataProvider.h"

@interface JZAudioPlayerManager()

@property (nonatomic, strong) NSMutableArray <JZFMAudioListModel *>*playlist;  
@property (nonatomic, strong) JZAudioPlayer *player;
@property (nonatomic, assign) NSUInteger curIndex;
@property (nonatomic, strong) NSPointerArray <JZAudioPlayerProtocol>*customers;


@property (nonatomic, assign) BOOL firstTime;   //只为解决索取播放历史的需求

@property (nonatomic, assign) CGFloat toPosition;

@property (nonatomic, assign) NSUInteger timePlayed;  //当前播放进度
@property (nonatomic, assign) NSUInteger duration;    //当前音频总时长


@end

@implementation JZAudioPlayerManager

@synthesize playlist = _playlist;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    _player = [[JZAudioPlayer alloc] init];
    _player.delegate = self;
    [self addNotification];

}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActiveNotification {

}

#pragma mark - Public
+ (instancetype)sharedInstance {
    static JZAudioPlayerManager* JZAudioPlayerManager_Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JZAudioPlayerManager_Manager = [[JZAudioPlayerManager alloc] init];
    });
    
    return JZAudioPlayerManager_Manager;
}

- (void)seekToPosition:(float)position {
    [_player seekToPosition:position];
}
- (void)setVolume:(float)volume {
    [_player setVolume:volume];
}

- (void)playWithIndex:(NSUInteger)index {
    if (_playlist.count > index) {
        _curIndex = index;
        JZFMAudioListModel *model = _playlist[index];
        [self playWithModel:model];
        [_player setPreviousTrackCmdEnable:[self hasPreviousItem]];
        [_player setNextTrackCmdEnable:[self hasNextItem]];
        
    } else {
        _curIndex = -1;
    }
}

- (void)pause {
    [_player pause];
}
- (void)recover {
    [_player recover];
}
- (void)stop {
    [_player stop];
}
- (void)next {
    if ([self hasNextItem]) {
        [self playWithIndex:_curIndex + 1];
    }
}


- (void)previous {
    if ([self hasPreviousItem]) {
        [self playWithIndex:_curIndex - 1];
    }
}

///逻辑相反而已
- (BOOL)hasNextItem {
    if (_playlist.count > (_curIndex + 1)) {
        return true;
    }
    return false;
}

- (BOOL)hasPreviousItem {
    if (_curIndex > 0) {
        return true;
    }
    return false;
}

- (NSUInteger)curItemIndex {
    return _curIndex;
}


- (JZFMAudioListModel *)curItem {
    if (self.playlist.count) {
        return _playlist[_curIndex];
    }
    return nil;
}

- (void)appendCustomer:(id<JZAudioPlayerManagerProtocol>)customer {
    if ([customer conformsToProtocol:@protocol(JZAudioPlayerManagerProtocol)]) {
        [self.customers addPointer:(void *)customer];
    }
}


#pragma mark - Private


#pragma mark - Accessor
- (NSPointerArray<JZAudioPlayerProtocol> *)customers {
    if (!_customers) {
        _customers = [NSPointerArray weakObjectsPointerArray];
    }
    return _customers;
}

- (JZAudioPlayerStatus)status {
    return [_player status];
}

- (NSMutableArray *)playlist {
    if (!_playlist) {
        _playlist = [NSMutableArray array];
    }
    return _playlist;
}

- (void)playWithModel:(JZFMAudioListModel *)model {
    
    
    _firstTime = true;
    JZAudioPlayerItem *item =  JZAudioPlayerItem.new;
    item.url = [NSURL URLWithString:model.url];
    item.title = model.name;
    item.coverURL = [NSURL URLWithString:model.logoUrl];
    //    item.artist =
    //    item.albumTitle
    //    item.cover =
    
    item.duration = model.duration.unsignedIntegerValue;
    item.playbackTime = 0;
   
    
    [_player playWithItem:item];
}

#pragma mark - JZAudioPlayerProtocol
- (void)audioPlayerTimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration {

    _timePlayed = timePlayed;
    _duration = duration;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerTimePlayed:duration:)]) {
                [obj audioPlayerTimePlayed:timePlayed duration:duration];
            }
        }
    });
}

- (void)audioPlayerTotalBytesWritten:(int64_t)totalBytesWritten
           totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerTotalBytesWritten:totalBytesExpectedToWrite:)]) {
                [obj audioPlayerTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
            }
        }
    });
}

- (void)audioPlayerWillPlay {
    [self.customers compact];//清空null对象
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerWillPlay)]) {
                [obj audioPlayerWillPlay];
            }
        }
    });
}

- (void)audioPlayerPlaying {
    
    CGFloat position = 0;
    if (_toPosition > 0) {
        position = _toPosition;
        _toPosition = 0;
    } else {
    }
    if (position > 0) {
        if (position > 0.99) {
            position = 0;
        }
        [_player seekToPosition:position];
    }

    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerPlaying)]) {
                [obj audioPlayerPlaying];
            }
        }
    });
}

- (void)audioPlayerPaused {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerPaused)]) {
                [obj audioPlayerPaused];
            }
        }
    });
}

- (void)audioPlayerStopped {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerStopped)]) {
                [obj audioPlayerStopped];
            }
        }
    });
}

- (void)audioPlayerPlayedCompleted {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerPlayedCompleted)]) {
                [obj audioPlayerPlayedCompleted];
            }
        }
    });
    
    if ([self hasNextItem]) {
        [self next];
    }
}

- (void)audioPlayerOnFailWithError:(JZAudioPlayerError)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerOnFailWithError:)]) {
                [obj audioPlayerOnFailWithError:error];
            }
        }
    });
}

- (void)audioPlayerNext {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerNext)]) {
                [obj audioPlayerNext];
            }
        }
    });
}

- (void)audioPlayerPrevious {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <JZAudioPlayerManagerProtocol>obj in self.customers) {
            if ([obj respondsToSelector:@selector(audioPlayerPrevious)]) {
                [obj audioPlayerPrevious];
            }
        }
    });
}

- (void)audioPlayerSeekToTimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration {

    CGFloat position = (timePlayed * 1.0 / duration);
    if (_player.status == JZAudioPlayerStatusStopped) {
        NSAssert(0, @"矫正");
    } else {
        [self seekToPosition:position];
    }
}



@end
