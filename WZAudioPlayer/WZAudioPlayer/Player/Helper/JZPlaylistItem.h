//
//  JZPlaylistItem.h
//   
//
//  Created by liweizhao on 2018/4/21.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "FSPlaylistItem.h"
#import "JZRemoteCommandManager.h"

@interface JZPlaylistItem : FSPlaylistItem

//媒体信息 由网络接口返回的媒体信息转为专用的模型
@property (nonatomic, strong) JZNowPlayingInfoModel *infoModel;


@end
