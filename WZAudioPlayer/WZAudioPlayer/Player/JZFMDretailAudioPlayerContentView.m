//
//  JZFMDretailAudioPlayerContentView.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/3.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMDretailAudioPlayerContentView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JZFMAudioTitleMarquee.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "JZFMAudioListModel.h"

@interface JZFMDretailAudioPlayerContentView ()

@property (nonatomic, strong) UIImageView *bgImageView;         //背景图
@property (nonatomic, strong) UIImageView *pathImageView;       //返回显示图片
@property (nonatomic, strong) UIButton *pathButton;             //返回按钮
@property (nonatomic, strong) UIScrollView *scrollView;         //

@property (nonatomic, strong) UIView *coverContainer;           //封面容器
@property (nonatomic, strong) UIImageView *coverView;           //封面
@property (nonatomic, strong) UIVisualEffectView *effectView;   //玻璃遮罩

@property (nonatomic, strong) JZFMAudioTitleMarquee *titleView;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationPreogress;

//相关推荐部分
@property (nonatomic, strong) NSMutableArray <JZFMAudioListModel *>*dataSource;

@end

@implementation JZFMDretailAudioPlayerContentView

- (void)dealloc {
    [_titleView stop];
    _displayLink.paused = true;
    [_displayLink invalidate];
    _displayLink = nil;
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
    //需要模糊效果的view
    _bgImageView = UIImageView.alloc.init;
    [self addSubview:_bgImageView];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.image = [UIImage imageNamed:@"icon_FM_Placeholder"];
    _bgImageView.clipsToBounds = true;
    _bgImageView.userInteractionEnabled = true;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _effectView.alpha = 1.0;
    [_bgImageView addSubview:_effectView];
   
    _pathImageView = UIImageView.alloc.init;
    [_bgImageView addSubview:_pathImageView];
    _pathImageView.contentMode = UIViewContentModeScaleAspectFill;
    _pathImageView.image = [UIImage imageNamed:@"btn_FM_AudioPath"];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.showsHorizontalScrollIndicator = false;
    [self addSubview:_scrollView];
    _scrollView.pagingEnabled = true;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 0.0);
    _scrollView.backgroundColor = UIColor.clearColor;
    _scrollView.bounces = false;
    
    _pathButton = UIButton.alloc.init;
    [_bgImageView addSubview:_pathButton];
    _pathButton.backgroundColor = UIColor.clearColor;
    [_pathButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat coverWH =  320.0 / 375.0 * UIScreen.mainScreen.bounds.size.width;
    _coverContainer = UIView.alloc.init;
    [_scrollView addSubview:_coverContainer];
    _coverContainer.layer.cornerRadius = coverWH / 2.0;
    _coverContainer.layer.masksToBounds = true;
    _coverContainer.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.1];
    
    _coverView = UIImageView.alloc.init;
    [_coverContainer addSubview:_coverView];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.image = [UIImage imageNamed:@"icon_FM_Placeholder"];
    
    coverWH = coverWH - 10.0 * 2.0;//top bottom
    _coverView.layer.cornerRadius = coverWH / 2.0;
    _coverView.layer.masksToBounds = true;
    
    
  
    CGFloat y = UIScreen.mainScreen.bounds.size.height - 167.0 - 45.3 - 25.0;
    if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
        y = y - 44.0;
    }
    if (UIScreen.mainScreen.bounds.size.width - 320.0 < 1.0) {    ///适配小屏幕
        y = y + 25.0;
    }
    CGFloat w = UIScreen.mainScreen.bounds.size.width - 30.0;
    _titleView = [[JZFMAudioTitleMarquee alloc] initWithFrame:CGRectMake(15.0, y, w, 25.0)];
    [self addSubview:_titleView];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_bgImageView);
    }];
    
    [_pathImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@29.0);
        make.height.equalTo(@10.0);
        make.centerX.equalTo(self.mas_centerX);
        CGFloat offset = 30;

        if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(offset);
            }
        } else {
            make.top.equalTo(@(offset));
        }
        
    }];
    
    [_pathButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(29.0 + 20.0));
        make.height.equalTo(@(10.0 + 20.0));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(_pathImageView.mas_top).offset(-10.0);
    }];
    
 
   CGFloat coverWH =  320.0 / 375.0 * UIScreen.mainScreen.bounds.size.width;
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 19.0;
        CGFloat height = 40.0 + 110.0 * 3.0;
        
        if (UIScreen.mainScreen.bounds.size.width - 320.0 < 1.0) {    ///适配小屏幕
            offset = 0.0;
            height = 40.0 + 110.0 * 2.7;
        }
        
        if (UIScreen.mainScreen.bounds.size.width - 320.0 > 1) {
            CGFloat fixW = (coverWH + (60.0 - 19.0) * 2.0); /// 适配大屏幕
            if (fixW > height) {
                height = fixW;
            }
        }
        
        CGFloat controlH = 167.0;
        if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] bounds].size.height == 812.0f)) {
            controlH = 167.0 + 34.0;
        }
        make.bottom.equalTo(self.mas_bottom).offset(-(UIScreen.mainScreen.bounds.size.height - controlH - CGRectGetMaxY(_titleView.frame)));
        make.left.width.equalTo(self);
      
        make.top.equalTo(self.pathImageView.mas_bottom).offset(offset);
    }];
    
    [_coverContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 60.0 - 19.0;
        if (UIScreen.mainScreen.bounds.size.width - 320.0 < 1.0) {
            offset = 30.0;
        }
        make.top.equalTo(_scrollView.mas_top).offset(offset);
        make.centerX.equalTo(_scrollView.mas_centerX);
        make.width.height.equalTo(@(coverWH));
    }];
    
    coverWH = coverWH - 10.0 * 2.0;
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_coverContainer).offset(10.0);
        make.width.height.equalTo(@(coverWH));
    }];
    
  
    
 
}

- (void)clickedBtn:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(audioPlayerContentViewClickedPathButton)]) {
        [_delegate audioPlayerContentViewClickedPathButton];
    }
}

- (void)displayLink:(CADisplayLink *)sender {
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 2.0 * _animationPreogress);
    _coverView.transform = transform;
    _animationPreogress = 1.0 / 60.0 / 10 / 2.0  + _animationPreogress;
    if (_animationPreogress > 1.0) {
        _animationPreogress = 0;
    }
}

#pragma mark - Public
- (void)scrollToX:(CGFloat)x {
    _scrollView.contentOffset = CGPointMake(x, 0);
}

- (void)updateCoverWithURL:(NSURL *)url {
    [_bgImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
             _coverView.image = image;
        });
    }];
}

- (void)updateTableViewWithArray:(NSArray <JZFMAudioListModel *> *)array {
    _dataSource = [NSMutableArray arrayWithArray:array];
}


- (void)updateTitle:(NSString *)title {
    if (![title isKindOfClass:[NSString class]]) {
        title = @" ";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_titleView updateWithTitle:title];
    });
}


- (void)disable:(BOOL)boolean {
    [self showPlayStatus:!boolean];
}

- (void)showPlayStatus:(BOOL)boolean {
    if (boolean) {
        [self.titleView run];
        [self recoverAnimation];
    } else {
        [self.titleView pause];
        [self pauseAnimation];
    }
}

- (void)addAnimation {
    _animationPreogress = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(displayLink:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.paused = true;
}

- (void)pauseAnimation {
    if (_displayLink.paused != true) {
        _displayLink.paused = true;
    }
}

- (void)recoverAnimation {
    if (_displayLink.paused != false) {
        _displayLink.paused = false;
    }
}

- (void)removeAnimation {
    _displayLink.paused = true;
    _animationPreogress = 0.0;
    [_displayLink invalidate];
    _displayLink = nil;
    _coverView.transform = CGAffineTransformIdentity;
}

#pragma mark - Accessor
- (NSMutableArray<JZFMAudioListModel *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
