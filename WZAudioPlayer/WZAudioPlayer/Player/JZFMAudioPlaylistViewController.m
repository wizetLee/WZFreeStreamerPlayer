//
//  JZFMAudioPlaylistViewController.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/4.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMAudioPlaylistViewController.h"
#import "JZFMAudioPlaylistView.h"
#import "JZAudioPlayerManager.h"

#import "JZTransition_FadeDismiss.h"
#import "JZTransition_FadePresent.h"
#import "JZFMAudioListModel.h"
#import <Masonry/Masonry.h>

@interface JZFMAudioPlaylistViewController ()<JZFMAudioPlaylistViewProtocol, JZAudioPlayerManagerProtocol>

@property (nonatomic, strong) JZFMAudioPlaylistView *playlistView;
@property (nonatomic, strong) JZFMAudioPlaylistHeader *header;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic,   weak) JZAudioPlayerManager *manager;

@end

@implementation JZFMAudioPlaylistViewController



- (instancetype)initWithModel:(id)model {
    if (self = [super init]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        _manager = [JZAudioPlayerManager sharedInstance];
        [_manager appendCustomer:self];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        _manager = [JZAudioPlayerManager sharedInstance];
        [_manager appendCustomer:self];
        [self initView];
        [self initData];
    }
    return self;
}


- (void)initView {
    self.view.backgroundColor = UIColor.clearColor;
    
    ///点击退出层
    UIView *tapView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:tapView];
    tapView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [tapView addGestureRecognizer:tap];
    
    _closeBtn = UIButton.alloc.init;
    [self.view addSubview:_closeBtn];
    _closeBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.backgroundColor = UIColor.whiteColor;
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50.0);
        if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    UIView *line = UIView.alloc.init;
    [_closeBtn addSubview:line];
    line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_closeBtn.mas_top);
        make.height.equalTo(@0.5);
        make.right.left.equalTo(_closeBtn);
    }];
    
    _playlistView = [[JZFMAudioPlaylistView alloc] init];
    _playlistView.delegate = self;
    [self.view addSubview:_playlistView];
    [_playlistView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.width.equalTo(self.view);
        CGFloat top = 167.0 + 40.0;//40 -> header_h
        if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
            top = top + 40.0;
        }
        make.top.equalTo(self.view.mas_top).offset(top);
        make.bottom.equalTo(_closeBtn.mas_top);
    }];
    
    _header = [[JZFMAudioPlaylistHeader alloc] init];
    [self.view addSubview:_header];
    [_header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_playlistView.mas_top);
        make.height.equalTo(@(40.0));
        make.left.right.equalTo(self.view);
    }];
    
    
    __weak typeof(self) weakSelf = self;
    _header.didClickCloseBlock = ^{
        [weakSelf dismiss];
    };
    
}

- (void)initData {
     
}

- (void)clickedBtn:(UIButton *)sender {
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:^{}];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    JZTransition_FadePresent *present = JZTransition_FadePresent.alloc.init;
    present.orientationType = JZTransitionOrientationType_Bottom;
    return present;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    JZTransition_FadeDismiss *dismiss = JZTransition_FadeDismiss.alloc.init;
    dismiss.orientationType = JZTransitionOrientationType_Bottom;
    return dismiss;
}

#pragma mark - JZFMAudioPlaylistViewProtocol
- (void)audioPlaylistViewDidSelectAtIndexPath:(NSIndexPath *)indexPath {
    if (_manager.playlist.count > indexPath.row) {
        if (_manager.status == JZAudioPlayerStatusPlaying) {
            [_manager playWithIndex:indexPath.row];
        } else if (_manager.status == JZAudioPlayerStatusPaused) {
            [_manager recover];
        }
    }
}

@end
