//
//  JZFMAudioTitleMarquee.m
//  
//
//  Created by liweizhao on 2018/4/28.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZFMAudioTitleMarquee.h"
#import <YYKit/YYKit.h>

@interface  JZFMAudioTitleMarquee() <UIScrollViewDelegate>

@property (nonatomic, strong) UIFont *targetFont;
@property (nonatomic, assign) CGFloat targetWidth;                          //此处为frame的长度

@property (nonatomic,   copy) NSString *title;                              //标题

@property (nonatomic, assign) BOOL needScroll;                              //判断是否需要滑动

@property (nonatomic, strong) CADisplayLink *displayLink;                   //移动定时器
@property (nonatomic, assign) float interval;                               //驻留间隔
@property (nonatomic, assign) CGFloat gap;                                  //当needScroll == true时，滑动间隔

///复用控件
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation JZFMAudioTitleMarquee

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.layer.masksToBounds = true;
    
    _gap = 20.0;
 
    _scrollView = UIScrollView.alloc.init;
    _scrollView.frame = self.bounds;
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.scrollEnabled = false;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_scrollView addGestureRecognizer:press];
    
    
    _label1 = UILabel.alloc.init;
    _label2 = UILabel.alloc.init;
    _label1.font = _targetFont;
    _label2.font = _targetFont;
    _label1.textColor = [UIColor whiteColor];
    _label2.textColor = [UIColor whiteColor];
    _label1.textAlignment = NSTextAlignmentCenter;
    _label2.textAlignment = NSTextAlignmentCenter;
    
    [_scrollView addSubview:_label1];
    [_scrollView addSubview:_label2];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    //重新布局
    if (_title) {
        [self updateWithTitle:_title];
    }
    
}

#pragma mark - Public
- (void)updateWithTitle:(NSString *)title {
    _title = title;
    
    _displayLink.paused = true;
    [_displayLink invalidate];
    _displayLink = nil;
    
    _label1.text = title;
    [_label1 sizeToFit];
    _label2.text = title;
    [_label1 sizeToFit];
    
    //滑动条件--字符渲染尺寸长度大于此控件长度
    _needScroll = _label1.frame.size.width > self.frame.size.width;
    
    if (_needScroll) {
        _displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(displayLink:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = false;
        
        _label1.frame = CGRectMake(0.0, 0.0, _label1.frame.size.width, _label1.frame.size.height);
        _label2.frame = CGRectMake(_gap + CGRectGetMaxX(_label1.frame), 0.0, _label1.frame.size.width, _label1.frame.size.height);
        [_scrollView setContentSize:CGSizeMake(_label1.frame.size.width * 2.0 + _gap, 0)];
    } else {
        //label居中显示
        _label1.frame = CGRectMake(0.0, 0.0, self.frame.size.width, _label1.frame.size.height);
        _label2.frame = CGRectZero;
        [_scrollView setContentSize:CGSizeZero];
    }
    

}

- (void)run {
    _displayLink.paused = false;
}

- (void)pause {
    _displayLink.paused = true;
}

- (void)stop {
    _displayLink.paused = true;
    [_displayLink invalidate];
    _displayLink = nil;
}


#pragma mark - Private
- (void)displayLink:(CADisplayLink *)sender {
    
    //UI 无限轮播逻辑..取巧
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat x = (_scrollView.contentOffset.x + 1);
        if (x == CGRectGetMinX(_label2.frame)) {                //精度可能有点不足
            x = 0.0;
        } else if ((x - CGRectGetMinX(_label2.frame)) > 0.5) {  //精度可能有点不足
            x = 1.0;
        }
        [_scrollView setContentOffset:CGPointMake(x, 0.0)];
    });
    
    //驻留时间过渡掉(return)
    
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    //可以做显示title的调用
}

#pragma mark - Accessor
- (UIFont *)targetFont {
    if (_targetFont == nil) {
        _targetFont = [UIFont systemFontOfSize:18.0];
    }
    
    return _targetFont;
}

@end
