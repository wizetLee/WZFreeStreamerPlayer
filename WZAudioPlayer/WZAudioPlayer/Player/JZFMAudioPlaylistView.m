//
//  JZFMAudioPlaylistView.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/5.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMAudioPlaylistView.h"
#import "JZCircularProgressLayer.h"
#import "JZFMAudioListModel.h"
#import "JZAudioPlayerManager.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+GIF.h>

@interface JZFMAudioPlaylistCell()
@property (nonatomic, strong) YYLabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *listenerCountLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *historylLabel;
@property (nonatomic, strong) UIImageView *listenerCountImgV;
@property (nonatomic, strong) UIImageView *durationImgV;

@property (nonatomic, strong) UILabel *orderLabel;
@property (nonatomic, strong) UIView *progressLayerContainer;
@property (nonatomic, strong) JZCircularProgressLayer *progressLayer;       //播放进度

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *dynamicLineImgV;
@property (nonatomic, strong) UIImage *gif;

@property (nonatomic,   weak) JZAudioPlayerManager *manager;

@end

@implementation JZFMAudioPlaylistCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _manager = [JZAudioPlayerManager sharedInstance];

        [self initViews];
        
    }
    
    return self;
}

- (void)initViews {
    _titleLabel = YYLabel.alloc.init;
    _titleLabel.text = @"  ";
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.numberOfLines = 0;
    
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];

    _listenerCountLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_listenerCountLabel];
    _listenerCountLabel.textColor = [UIColor grayColor];
    _listenerCountLabel.font = [UIFont systemFontOfSize:12.0];
    
    _durationLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_durationLabel];
    _durationLabel.textColor = [UIColor grayColor];
    _durationLabel.font = [UIFont systemFontOfSize:12.0];
    
    
    _historylLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_historylLabel];
    _historylLabel.textColor = [UIColor orangeColor];
    _historylLabel.font = [UIFont systemFontOfSize:12.0];
    
    _listenerCountImgV = [[UIImageView alloc] init];
    [self.contentView addSubview:_listenerCountImgV];
    _listenerCountImgV.contentMode = UIViewContentModeScaleAspectFit;

    _durationImgV = [[UIImageView alloc] init];
    [self.contentView addSubview:_durationImgV];
    _durationImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    _orderLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_orderLabel];
    _orderLabel.textColor = [UIColor blackColor];
    _orderLabel.font = [UIFont systemFontOfSize:14.0];
    _orderLabel.textAlignment = NSTextAlignmentCenter;
    
    _progressLayerContainer = UIView.alloc.init;
    [self.contentView addSubview:_progressLayerContainer];
    _progressLayer = [[JZCircularProgressLayer alloc] initWithCircleRadius:10.0 layerLineWidth:2.0];
    _progressLayer.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    [_progressLayerContainer.layer addSublayer:_progressLayer];
    
    
    _line = [[UIView alloc] init];
    [self.contentView addSubview:_line];
    _line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(54.0);
        make.top.equalTo(self.contentView).offset(12.0);
        make.right.equalTo(self.contentView).offset(-15.0);
        
        CGFloat width = UIScreen.mainScreen.bounds.size.width - 54.0 - 15.0;
        CGFloat height = [self.class getLabelHeightWithText:_titleLabel.text width:width font:_titleLabel.font];
        make.height.equalTo(@(height));     //临时高度 赋值时需要更新
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5.0);
        make.width.equalTo(@70.0);
        make.bottom.equalTo(@(-13.5));
    }];
    
    [_listenerCountImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_top).offset(3.5);//H = 17.0
        make.width.height.equalTo(@(10.0));
        make.left.equalTo(_timeLabel.mas_right).offset(15.0);
    }];
    
    [_listenerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_top);
        make.height.equalTo(@(17.0));
        make.width.equalTo(@40.0);
        make.left.equalTo(_listenerCountImgV.mas_right).offset(3.0);
    }];
    
    [_durationImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_top).offset(3.5);//H = 17.0
        make.width.height.equalTo(@(10.0));
        make.left.equalTo(_listenerCountLabel.mas_right).offset(14.0);
    }];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_top);
        make.height.equalTo(@(17.0));
        make.width.equalTo(@35.0);
        make.left.equalTo(_durationImgV.mas_right).offset(3.0);
    }];
    
    [_historylLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_top);
        make.height.equalTo(@(17.0));
        make.right.equalTo(self.contentView.mas_right);
        make.left.equalTo(_durationLabel.mas_right).offset(13.0);
    }];
    
    [_orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@54.0);
        make.height.equalTo(@20.0);
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-25.0);
    }];
    
    [_progressLayerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(((54.0 - 20.0) / 2.0));
        make.width.height.equalTo(@20.0);
         make.bottom.equalTo(self.contentView.mas_bottom).offset(-25.0);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.left.equalTo(self.contentView).offset(54);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    _titleLabel.text = @"     ";
    _timeLabel.text = @"   ";
    _durationLabel.text = @"  ";
    _listenerCountImgV.image = [UIImage imageNamed:@"icon_FM_AudioPlaylistListener"];
    _durationImgV.image = [UIImage imageNamed:@"icon_FM_AudioPlaylistDuration"];
    _orderLabel.text = @"  ";
    _listenerCountLabel.text = @"   ";
    _historylLabel.text = @"已听0%";
    
    
    static UIImage *icon_FM_DynamicLineGIF;
    if (!icon_FM_DynamicLineGIF) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"icon_FM_DynamicLine"ofType:@"gif"];
        NSData* data = [NSData dataWithContentsOfFile:path];
        icon_FM_DynamicLineGIF = [UIImage sd_animatedGIFWithData:data];
    }
    _gif = icon_FM_DynamicLineGIF;
    
    _dynamicLineImgV = [[UIImageView alloc] init];
    _dynamicLineImgV.image = [UIImage imageNamed:@"icon_FM_DynamicLine"];
    [self.contentView addSubview:_dynamicLineImgV];
    _dynamicLineImgV.contentMode = UIViewContentModeScaleAspectFit;
    _dynamicLineImgV.hidden = true;
    
    
    [_dynamicLineImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(16.0));
        make.height.equalTo(@(13.0));
        make.centerX.centerY.equalTo(_orderLabel);
    }];
}

- (void)updateProgress:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = notification.object;
        if (dic[@"timePlayed"] && dic[@"duration"]) {
            //更新进度
            NSUInteger timePlayed = [dic[@"timePlayed"] unsignedIntegerValue];
            NSUInteger duration = [dic[@"duration"] unsignedIntegerValue];
            if (duration) {
                CGFloat scale = (timePlayed * 1.0) / duration;
                if (scale > 1) {
                    scale = 1;
                }
                //更新进度
                [_progressLayer setRenderAngle:M_PI * 2.0 * scale];
            }
        }
    }
}

#pragma mark - Public
- (void)updateIndex:(NSUInteger)index {
    _orderLabel.text = [NSString stringWithFormat:@"%ld", index];
}

- (void)updateWithModel:(JZFMAudioListModel *)model {
    
    NSMutableAttributedString *content = nil;
    CGFloat height = 0;
    if (model.nameAtr) {
        //使用缓存
        content = model.nameAtr;
        height = model.nameAtrHeight;
    } else if (model.name && model.name.length) {

        content = [[NSMutableAttributedString alloc] initWithString:model.name];
        content.font = [UIFont systemFontOfSize:17.0];
        content.color = [UIColor blackColor];
        CGFloat width = UIScreen.mainScreen.bounds.size.width - 54.0 - 15.0;
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(width, MAXFLOAT)];
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:content];
        height = layout.textBoundingSize.height;
        
        model.nameAtr = content;
        model.nameAtrHeight = height;
    }
    
    _titleLabel.attributedText = content;
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(54.0);
        make.top.equalTo(self.contentView).offset(12.0);
        make.right.equalTo(self.contentView).offset(-15.0);
        make.height.equalTo(@(height));
    }];
    
    self.state = JZFMAudioPlaylistCellState_Normal;
    
}

+ (CGFloat)getLabelHeightWithText:(NSString *)text width:(CGFloat)width font: (UIFont *)font{
    if (!text || text.length == 0) {
        return 0;
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
     return rect.size.height;
}


- (void)setState:(JZFMAudioPlaylistCellState)state {
    _state = state;
    _durationLabel.hidden = false;
    _orderLabel.hidden = false;
    _durationLabel.hidden = false;
     _progressLayer.hidden = true;
    _historylLabel.hidden = false;
    _dynamicLineImgV.hidden = true;
    _historylLabel.textColor = [UIColor orangeColor];
    _durationImgV.hidden = false;
    _orderLabel.textColor = [UIColor blackColor];
    _historylLabel.text = @"  ";
    
    
    
    if ([_titleLabel.attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        ((NSMutableAttributedString *)_titleLabel.attributedText).color = [UIColor blackColor];
    }
    
    switch (state) {
        case JZFMAudioPlaylistCellState_Normal: {
            _historylLabel.hidden = true;
        } break;
            
        case JZFMAudioPlaylistCellState_Playing: {
            if ([_titleLabel.attributedText isKindOfClass:[NSMutableAttributedString class]]) {
                ((NSMutableAttributedString *)_titleLabel.attributedText).color = [UIColor blueColor];
            }
            
            _dynamicLineImgV.image = nil;
            _dynamicLineImgV.image = _gif;
            _dynamicLineImgV.hidden = false;
            _orderLabel.hidden = true;
            _historylLabel.hidden = true;
//            _progressLayer.renderAngle = 0.0;
        } break;
            
        case JZFMAudioPlaylistCellState_Paused: {
            if ([_titleLabel.attributedText isKindOfClass:[NSMutableAttributedString class]]) {
                ((NSMutableAttributedString *)_titleLabel.attributedText).color = [UIColor blueColor];
            }
            _dynamicLineImgV.image = nil;
            _dynamicLineImgV.image = [UIImage imageNamed:@"icon_FM_DynamicLine"];
            _dynamicLineImgV.hidden = false;
            
            _orderLabel.hidden = true;
            _historylLabel.hidden = true;
        } break;
         
        case JZFMAudioPlaylistCellState_Played: {
           
        } break;
            
        case JZFMAudioPlaylistCellState_Over: {
            if ([_titleLabel.attributedText isKindOfClass:[NSMutableAttributedString class]]) {
                ((NSMutableAttributedString *)_titleLabel.attributedText).color = [UIColor grayColor];
            }
            _historylLabel.textColor = [UIColor grayColor];
            _historylLabel.text = @"已听完";
            _orderLabel.textColor = [UIColor grayColor];
        } break;
        default:
            break;
    }
}

@end

@interface JZFMAudioPlaylistCell2()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *dynamicLineImgV;
@property (nonatomic, strong) UILabel *orderLabel;
@property (nonatomic, strong) UIImage *gif;

@end

@implementation JZFMAudioPlaylistCell2

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    _orderLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_orderLabel];
    _orderLabel.textColor = [UIColor blackColor];
    _orderLabel.font = [UIFont systemFontOfSize:14.0];
    _orderLabel.textAlignment = NSTextAlignmentCenter;
    
    _titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    
    _dynamicLineImgV = [[UIImageView alloc] init];
    _dynamicLineImgV.image = [UIImage imageNamed:@"icon_FM_DynamicLine"];
    [self.contentView addSubview:_dynamicLineImgV];
    _dynamicLineImgV.contentMode = UIViewContentModeScaleAspectFit;
    _dynamicLineImgV.hidden = true;
    
    static UIImage *icon_FM_DynamicLineGIF;
    if (!icon_FM_DynamicLineGIF) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"icon_FM_DynamicLine"ofType:@"gif"];
        NSData* data = [NSData dataWithContentsOfFile:path];
        icon_FM_DynamicLineGIF = [UIImage sd_animatedGIFWithData:data];
    }
   
    _gif = icon_FM_DynamicLineGIF;

    [_orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.height.equalTo(@(23.0));
        make.width.equalTo(@(52.0));
        make.top.equalTo(self.contentView).offset(13.5);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_orderLabel.mas_right);
        make.height.equalTo(@(23.0));
        make.right.equalTo(self.contentView).offset(-15.0);
        make.top.equalTo(_orderLabel.mas_top);
    }];
    
    [_dynamicLineImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(16.0));
        make.height.equalTo(@(13.0));
        make.centerX.centerY.equalTo(_orderLabel);
    }];
    
}

- (void)updateIndex:(NSUInteger)index {
    _orderLabel.text = [NSString stringWithFormat:@"%ld", index];
}

- (void)updateWithModel:(JZFMAudioListModel *)model {
    _titleLabel.text = model.name;
}

- (void)setState:(JZFMAudioPlaylistCellState)state {
  
    _state = state;
    ///改动UI方面的
    switch (state) {
        case JZFMAudioPlaylistCellState_Normal: {
            _titleLabel.textColor = [UIColor blackColor];
            _dynamicLineImgV.hidden = true;
            _orderLabel.hidden = false;
        } break;
            
        case JZFMAudioPlaylistCellState_Playing: {

            _dynamicLineImgV.image = nil;
            _dynamicLineImgV.image = _gif;
            _titleLabel.textColor = [UIColor blueColor];
            _dynamicLineImgV.hidden = false;
            _orderLabel.hidden = true;
        } break;
            
        case JZFMAudioPlaylistCellState_Paused: {
            _dynamicLineImgV.image = [UIImage imageNamed:@"icon_FM_DynamicLine"];
            _titleLabel.textColor = [UIColor blueColor];
            _dynamicLineImgV.hidden = false;
            _orderLabel.hidden = true;
        } break;
            
        default:
            break;
    }
}

@end

@interface JZFMAudioPlaylistHeader()
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) CAShapeLayer *bgLayer;
@end

@implementation JZFMAudioPlaylistHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = UIColor.clearColor;
    
    _bgLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, UIScreen.mainScreen.bounds.size.width, 40.0) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8.0, 8.0)];
    
    _bgLayer.path = path.CGPath;
    _bgLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_bgLayer];
    
    _closeBtn = UIButton.alloc.init;
    [self addSubview:_closeBtn];
    _closeBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -2.0, 0.0, 0.0);
    _closeBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0);
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];

    
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13.0));
        make.width.equalTo(@(52.0));
        make.height.equalTo(@(24.0));
        make.top.equalTo(@(8.0));
    }];
    
    UIView *line = UIView.alloc.init;
    line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(0.5));
    }];
    
    
    //暂停按钮
   
}

- (void)clickBtn:(UIButton *)btn {
    self.didClickCloseBlock();
}

@end


@interface JZFMAudioPlaylistView()<UITableViewDelegate, UITableViewDataSource, JZAudioPlayerManagerProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,   weak) NSMutableArray <JZFMAudioListModel *> *dataSource;
@property (nonatomic,   weak) JZAudioPlayerManager *manager;
@property (nonatomic,   weak) JZFMAudioListModel *curModel;

@end

@implementation JZFMAudioPlaylistView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
        _manager = [JZAudioPlayerManager sharedInstance];
        _dataSource = _manager.playlist;
        [_manager appendCustomer:self];
        
    }
    return self;
}

- (void)initViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:JZFMAudioPlaylistCell2.class forCellReuseIdentifier:NSStringFromClass(JZFMAudioPlaylistCell2.class)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = false;
    [self addSubview:_tableView];
    _tableView.estimatedRowHeight  = 50.0;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource.count > indexPath.row) {
        if ([_delegate respondsToSelector:@selector(audioPlaylistViewDidSelectAtIndexPath:)]) {
            [_delegate audioPlaylistViewDidSelectAtIndexPath:indexPath];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource ? _dataSource.count : 0;
}

- (JZFMAudioPlaylistCell2 *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JZFMAudioPlaylistCell2 *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JZFMAudioPlaylistCell2.class) forIndexPath:indexPath];
    
    cell.state = JZFMAudioPlaylistCellState_Normal;
    [cell updateWithModel:_dataSource[indexPath.row]];
    [cell updateIndex:indexPath.row + 1];
    
    return cell;
}

#pragma mark - JZAudioPlayerManagerProtocol
- (void)audioPlayerDidSetReverse:(BOOL)isReverse {
     [_tableView reloadData];
}

- (void)audioPlayerWillPlay {
    [_tableView reloadData];
}

- (void)audioPlayerPlaying {
    [_tableView reloadData];
}

- (void)audioPlayerPaused {
    [_tableView reloadData];
}

- (void)audioPlayerStopped {
    [_tableView reloadData];
}

- (void)audioPlayerPlayedCompleted {
    [_tableView reloadData];
}

#pragma mark - Accessor

#pragma mark - Public


@end

@interface JZFMDetailGuideView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,   copy) void (^scrolledBlock)(CGFloat x);

@end

@implementation JZFMDetailGuideView

+ (void)showInView:(UIView *)superView scrolledBlock:(void(^)(CGFloat x))block {
    if (!superView
        || [[NSUserDefaults standardUserDefaults] valueForKey:NSStringFromClass(self)]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:NSStringFromClass(self)];
    JZFMDetailGuideView *view = [[JZFMDetailGuideView alloc] init];
    view.scrolledBlock = block;
    [superView addSubview:view];
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
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.frame = screenBounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_FM_DetailGuide"]];
    CGFloat y = (screenBounds.size.height - 133.0 - 30.0) / 2.0;
    _imageView.frame = CGRectMake(0.0, y, screenBounds.size.width, 106.0);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"左滑查看相关推荐";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:14.0];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.frame = CGRectMake(0.0, CGRectGetMaxY(_imageView.frame) + 7.0, screenBounds.size.width, 20.0);
    //w = 106 h = 100
    // distance = 7
    //h = 20
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.bounds;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = true;
    _scrollView.contentSize = CGSizeMake(screenBounds.size.width * 2.0, 0.0);
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.showsHorizontalScrollIndicator = false;
    
    [self addSubview:_scrollView];
    [_scrollView addSubview:_imageView];
    [_scrollView addSubview:_titleLabel];
    
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrolledBlock){
        _scrolledBlock(scrollView.contentOffset.x);
    }
    if (scrollView.contentOffset.x >= scrollView.frame.size.width) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}



@end

