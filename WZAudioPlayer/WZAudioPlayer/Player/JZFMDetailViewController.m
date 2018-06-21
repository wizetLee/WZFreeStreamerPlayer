//
//  JZFMDetailViewController.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/4/26.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMDetailViewController.h"
#import "JZFMDretailAudioPlayerContentView.h"
#import "JZFMDretailAudioPlayerControlView.h"
#import "JZFMAudioPlaylistViewController.h"
#import "JZAudioPlayerManager.h"
#import "NSDate+JZTimestamp.h"
#import "JZFMAudioPlaylistView.h"
#import <Masonry/Masonry.h>

@interface JZFMDetailViewController () <JZFMDretailAudioPlayerControlViewProtocol, JZFMDretailAudioPlayerContentViewProtocol>

@property (nonatomic, strong) JZFMDretailAudioPlayerContentView *contentView;
@property (nonatomic, strong) JZFMDretailAudioPlayerControlView *controlView;

@property (nonatomic, strong) JZFMAlbumDetailModel *model;
@property (nonatomic,   weak) JZAudioPlayerManager *manager;

@property (nonatomic, assign) BOOL playStatus;

@end

@implementation JZFMDetailViewController

#pragma mark - Override

- (void)dealloc {
    [_contentView removeAnimation];
    NSLog(@"%s", __func__);
}

- (instancetype)init {

    if (self = [super init]) {
               //不显示bar
        self.view.backgroundColor = [UIColor whiteColor];
        _playStatus = false;
        _manager = [JZAudioPlayerManager sharedInstance];
        [_manager appendCustomer:self];
        
        
        [self initView];
        [self initData];
    }
    
    return self;
}

//首次初始化view
- (void)initView {
    
    _contentView = [[JZFMDretailAudioPlayerContentView alloc] init];
   
    _contentView.delegate = self;
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
         CGFloat height = [UIScreen mainScreen].bounds.size.height - 167;
         if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
                 height =  height - 44.0;
             }
         make.height.equalTo(@(height));
         make.left.top.width.equalTo(self.view);
     }];

    _controlView = [[JZFMDretailAudioPlayerControlView alloc] init];
 
    _controlView.delegate = self;
    [self.view addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.width.equalTo(@(UIScreen.mainScreen.bounds.size.width));
         make.top.equalTo(_contentView.mas_bottom).offset(-8.0);
         make.left.equalTo(self.view);
         make.bottom.equalTo(self.view);
    }];
 
    [JZFMDetailGuideView showInView:self.view scrolledBlock:^(CGFloat x){
        [_contentView scrollToX:x];
    }];
}

- (void)initData {
    
    [self requestPlaylist];               //获取播放列表
    [self requsetAlbumRecommend];         //获取相关专辑
    
}

#pragma mark - Private
- (void)requsetAlbumRecommend {
    
}

- (void)requestPlaylist {

    if (_manager.status == JZAudioPlayerStatusPlaying) {
        //如果选中的是当前正在播放的音频
        [self audioPlayerWillPlay];
        return;
    }
}


#pragma mark - JZFMDretailAudioPlayerControlViewProtocol
- (void)audioPlayerControlViewClickedItemInIndex:(NSUInteger)index {
    
    if (index == 1) {
        
    } else if (index == 2) {
     
    } else if (index == 3) {
     
    } else {
        ///data
        if (_manager.playlist && _manager.playlist.count) {
            JZFMAudioPlaylistViewController *vc = JZFMAudioPlaylistViewController.alloc.init;
            [self presentViewController:vc animated:true completion:^{}];
        }
    }
}

- (void)audioPlayerControlViewClickedPlayBtn {
    
    if (_manager.status == JZAudioPlayerStatusPlaying) {
       
    } else if (_manager.status ==  JZAudioPlayerStatusPaused) {
        [_manager recover];
    } else {
        [_manager playWithIndex:0];
    }
}

- (void)audioPlayerControlViewClickedPauseBtn {
    [_manager pause];
}
- (void)audioPlayerControlViewClickedPreviousBtn {
    [_manager previous];
    //更新右边的推荐项
}
- (void)audioPlayerControlViewClickedNextBtn {
    [_manager next];
    //更新右边的推荐项
}

- (void)audioPlayerControlViewProgressValueChange:(float)value dragging:(BOOL)dragging {
    if (dragging) {
 
    } else {
        if (value >=  0.99) {
            ///框架内bug：播放position为的1.0情况,没有返回播放完毕的回调，目前的处理方案为调整到0.99
            value = 0.99;
        }
        if (_manager.status == JZAudioPlayerStatusStopped) {
        } else if (_manager.status == JZAudioPlayerStatusPaused) {
            [_manager recover];
        }
        
        [_manager seekToPosition:value];
    }
}

#pragma mark - JZFMDretailAudioPlayerContentViewProtocol
- (void)audioPlayerContentViewClickedPathButton {
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - 应该需要接收通知处理player界面的信息

- (void)audioPlayerTimePlayed:(NSUInteger)timePlayed duration:(NSUInteger)duration {
    [_controlView leftTitle:[NSDate getMMSSFromSS:timePlayed]];
    [_controlView rightTitle:[NSDate getMMSSFromSS:duration]];
    [_controlView updateProgress:(timePlayed * 1.0 / duration)];
    
}

- (void)audioPlayerTotalBytesWritten:(int64_t)totalBytesWritten
           totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite) {
        CGFloat progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
        [_controlView updatePreloadProgress:progress];
    }
}

///状态恢复
- (void)audioPlayerWillPlay {
 [_controlView updatePreloadProgress:0.0];
    //即将播放 -> result 播放失败/播放成功
    
    [_contentView removeAnimation];
    [_contentView addAnimation];
    
    if (_manager.playlist.count) {
        [_contentView updateTitle:[_manager curItem].name];
        [_contentView updateCoverWithURL:[NSURL URLWithString:[_manager curItem].logoUrl]];

        NSUInteger curIndex = [_manager curItemIndex] + 1;
        [_controlView updatePlayListWithSum:_manager.playlist.count curIndex:curIndex];
        
        [_controlView leftTitle:[NSDate getMMSSFromSS:_manager.timePlayed]];
        [_controlView rightTitle:[NSDate getMMSSFromSS:_manager.duration]];
        [_controlView updateProgress:(_manager.timePlayed * 1.0 / _manager.duration)];
    }
    
    [self showPlayStatus:true];
}

- (void)audioPlayerPlaying {
   //播放和恢复播放
    [self showPlayStatus:true];
}

- (void)showPlayStatus:(BOOL)boolean {
    [_controlView hasNextItem:[_manager hasNextItem]];
    [_controlView hasPreviousItem:[_manager hasPreviousItem]];
    [_contentView showPlayStatus:boolean];
    [_controlView showPlayStatus:boolean];
}

- (void)audioPlayerPaused {
    [self showPlayStatus:false];
}

- (void)audioPlayerPlayedCompleted {
    //停止所有动画
    //检查是否存在下一音频
    //manager更新信息，通知需要
    [self showPlayStatus:false];
    [_contentView removeAnimation];
}

- (void)audioPlayerOnFailWithError:(JZAudioPlayerError)error {
    [self showPlayStatus:false];
    [_manager pause];
}

- (void)audioPlayerNext {
    [_manager next];
}

- (void)audioPlayerPrevious {
    [_manager previous];
}


@end

