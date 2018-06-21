//
//  JZAudioPlayerItem.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/2.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///配套音频播放器的通用层模型
@interface JZAudioPlayerItem : NSObject

@property (nonatomic, strong) NSURL *url;                       //资源链接

@property (nonatomic,   copy) NSString *title;                  //标题
@property (nonatomic,   copy) NSString *artist;                 //作者
@property (nonatomic,   copy) NSString *albumTitle;             //相簿名
@property (nonatomic, strong) UIImage *cover;                   //封面
@property (nonatomic, strong) NSURL *coverURL;                  //封面链接
@property (nonatomic, assign) NSUInteger duration;              //音频总时长
@property (nonatomic, assign) NSUInteger playbackTime;          //当前播放时间

@end
