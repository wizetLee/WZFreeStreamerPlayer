//
//  JZFMDretailAudioPlayerControlView.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/3.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMDretailAudioPlayerControlView.h"
#import <Masonry/Masonry.h>
#import "JZAudioPlayerManager.h"

@interface JZFMDetailAudioPlayerControlItemView()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic,   copy) void (^btnClickedBlock)();

@end

@implementation JZFMDetailAudioPlayerControlItemView

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setTitle:(NSString *)title icon:(UIImage *)icon {
    _iconView.image = icon;
    _titleLabel.text = title;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    
    _actionButton = [[UIButton alloc] init];
    [self addSubview:_actionButton];
    _actionButton.backgroundColor = UIColor.clearColor;
    [_actionButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _iconView = [[UIImageView alloc] init];
    [_actionButton addSubview:_iconView];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    _titleLabel = UILabel.alloc.init;
    [_actionButton addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:10.0];
    _titleLabel.textColor = [UIColor lightGrayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"title";
}

- (void)clickedBtn:(UIButton *)sender {
    if (_btnClickedBlock) {
        _btnClickedBlock();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.centerX.equalTo(self.mas_centerX);
        make.width.height.equalTo(self.mas_height);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_actionButton.mas_centerX);
        make.top.equalTo(@5.0);
        make.width.height.equalTo(@20.0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_actionButton.mas_centerX);
        make.top.equalTo(_iconView.mas_bottom).offset(3.5);
        make.left.right.equalTo(_actionButton);
        make.height.equalTo(@14.0);
    }];
}


@end



@interface JZFMDretailAudioPlayerControlView()

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSMutableArray <JZFMDetailAudioPlayerControlItemView *>*viewMArr;


@property (nonatomic, assign) BOOL playStatus;
@property (nonatomic, assign) BOOL dragging;

@property (nonatomic, strong) UIView *line;
@end

@implementation JZFMDretailAudioPlayerControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
        [self initViews];
    }
    return self;
}

- (void)defaultConfig {
    _playStatus = false;
    _dragging = false;
}

- (void)initViews {
    
    _container = UIView.alloc.init;
    [self addSubview:_container];
    _container.backgroundColor = [UIColor whiteColor];
    
    _slider = [[UISlider alloc] init];
    [_slider setThumbImage:[UIImage imageNamed:@"icon_FM_AudioPlaySlider"] forState:UIControlStateNormal];
    [self addSubview:_slider];
    [_slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(leave:)  forControlEvents:UIControlEventTouchUpInside];
    
    _line = [[UIView alloc] init];
    _line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75 ];

    _line.frame = CGRectMake(0.0, 16.0 / 2.0, 0, 2.0);
    [_slider addSubview:_line];
    
    _leftTimeLabel = UILabel.alloc.init;
    [_container addSubview:_leftTimeLabel];
    _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    _leftTimeLabel.textColor = [UIColor blackColor];
    _leftTimeLabel.font = [UIFont systemFontOfSize:10.0];
    
    _rightTimeLabel = UILabel.alloc.init;
    [_container addSubview:_rightTimeLabel];
    _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    _rightTimeLabel.textColor = [UIColor blackColor];
    _rightTimeLabel.font = [UIFont systemFontOfSize:10.0];
    
    
    _previousButton = UIButton.alloc.init;
    [_container addSubview:_previousButton];
    [_previousButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _playButton = UIButton.alloc.init;
    [_container addSubview:_playButton];
    [_playButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _nextButton = UIButton.alloc.init;
    [_container addSubview:_nextButton];
    [_nextButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    ///默认配置
    [self showPlayStatus:false];
    [self hasPreviousItem:false];
    [self hasNextItem:false];
    
    _leftTimeLabel.text = @"00:00";
    _rightTimeLabel.text = @"00:00";
    
    
    _viewMArr = NSMutableArray.array;
    NSArray <NSString *>*imageNameArr = @[@"icon_FM_AudioCatalogue", @"icon_FM_AudioArticle", @"icon_FM_AudioVisitors", @"icon_FM_AudioShare"];
    NSArray <NSString *>*titleArr = @[@"0/0", @"--", @"--", @"--"];
    for (int i = 0; i < titleArr.count; i++) {
        JZFMDetailAudioPlayerControlItemView *tmp = JZFMDetailAudioPlayerControlItemView.alloc.init;
        [_container addSubview:tmp];
        [_viewMArr addObject:tmp];
        [tmp setTitle:titleArr[i] icon:[UIImage imageNamed:imageNameArr[i]]];
        __weak typeof(self) ws = self;
        tmp.btnClickedBlock = ^{
            if ([ws.delegate respondsToSelector:@selector(audioPlayerControlViewClickedItemInIndex:)]) {
                [ws.delegate audioPlayerControlViewClickedItemInIndex:i];
            }
        };
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    //height 167.0 + 8.0
    
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@16.0);
        make.width.equalTo(@(UIScreen.mainScreen.bounds.size.width));
        make.left.top.equalTo(self);
    }];
    [_slider insertSubview:_line atIndex:1];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@8.0);
        make.left.equalTo(self);
        make.width.equalTo(@(UIScreen.mainScreen.bounds.size.width));
        make.bottom.equalTo(self);
    }];
    
    
    [_leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_container);
        make.top.equalTo(_container).offset(4.0);
        make.width.equalTo(@(15.0 + 31.0 + 15.0));
        make.height.equalTo(@(14.0));
    }];
    
    [_rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_container);
        make.top.equalTo(_container).offset(4.0);
        make.width.equalTo(@(15.0 + 31.0 + 15.0));
        make.height.equalTo(@(14.0));
    }];
 
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_container.mas_centerX);
        make.top.equalTo(_leftTimeLabel.mas_bottom).offset(19.0);
        make.width.height.equalTo(@60.0);
    }];
    
    [_previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playButton.mas_centerY);
        make.right.equalTo(_playButton.mas_left).offset(-41.0);
        make.height.equalTo(@(36.0));
        make.width.equalTo(@(35.0));
    }];
    
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playButton.mas_centerY);
        make.left.equalTo(_playButton.mas_right).offset(41.0);
        make.height.equalTo(@(36.0));
        make.width.equalTo(@(35.0));
    }];
    
   
    
    ///等长设置
    [_viewMArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0.0 leadSpacing:0.0 tailSpacing:0.0];
    [_viewMArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playButton.mas_bottom).offset(22.0);
        make.height.equalTo(@47.5);
    }];
    
    
}

#pragma mark - Action
- (void)slider:(UISlider *)slider {
    _dragging = true;
    if ([_delegate respondsToSelector:@selector(audioPlayerControlViewProgressValueChange:dragging:)]) {
        [_delegate audioPlayerControlViewProgressValueChange:slider.value dragging:_dragging];
    }
}

- (void)leave:(UISlider *)slider {
    //恢复播放 or 开始播放
    _dragging = false;
    if ([_delegate respondsToSelector:@selector(audioPlayerControlViewProgressValueChange:dragging:)]) {
        [_delegate audioPlayerControlViewProgressValueChange:slider.value dragging:_dragging];
    }
    
}

- (void)clickedBtn:(UIButton *)sender {
    if (sender == _nextButton) {
        if ([_delegate respondsToSelector:@selector(audioPlayerControlViewClickedNextBtn)]) {
            [_delegate audioPlayerControlViewClickedNextBtn];
        }
    } else if (sender == _previousButton) {
        if ([_delegate respondsToSelector:@selector(audioPlayerControlViewClickedPreviousBtn)]) {
            [_delegate audioPlayerControlViewClickedPreviousBtn];
        }
    } else if (sender == _playButton) {
        //判断状态
        if (_playStatus) {
            
            if ([_delegate respondsToSelector:@selector(audioPlayerControlViewClickedPauseBtn)]) {
                [_delegate audioPlayerControlViewClickedPauseBtn];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(audioPlayerControlViewClickedPlayBtn)]) {
                [_delegate audioPlayerControlViewClickedPlayBtn];
            }
        }
    }
}


#pragma mark - Public

- (void)disable:(BOOL)boolean {
    [self showPlayStatus:!boolean];
    [self hasNextItem:!boolean];
    [self hasPreviousItem:!boolean];
}

- (void)updatePlayListWithSum:(NSUInteger)sum curIndex:(NSUInteger)index {
    [_viewMArr.firstObject setTitle:[NSString stringWithFormat:@"%lu/%lu", index, sum]];
}

- (void)showPlayStatus:(BOOL)boolean {
    _playStatus = boolean;
    NSString *imageName = boolean ? @"btn_FM_AudioPause" : @"btn_FM_AudioPlay";
    [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
}

- (void)hasPreviousItem:(BOOL)boolean {
    NSString *imageName = boolean ? @"btn_FM_AudioPlayPrevious" : @"btn_FM_AudioPlayPrevious_None";
    [_previousButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_previousButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    _previousButton.userInteractionEnabled = boolean;
}

- (void)hasNextItem:(BOOL)boolean {
    NSString *imageName = boolean ? @"btn_FM_AudioPlayNext" : @"btn_FM_AudioPlayNext_None";
    [_nextButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_nextButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    _nextButton.userInteractionEnabled = boolean;
}

- (void)leftTitle:(NSString *)title {
    _leftTimeLabel.text = title;
}

- (void)rightTitle:(NSString *)title {
    _rightTimeLabel.text = title;
}

- (void)updateProgress:(float)progress {
    if (_dragging) {
        return;
    }
    _slider.value = progress;
}

- (void)updatePreloadProgress:(float)progress {
    _line.frame = CGRectMake(_line.frame.origin.x, _line.frame.origin.y, UIScreen.mainScreen.bounds.size.width * progress, _line.frame.size.height);
}

@end
