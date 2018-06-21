//
//  JZPlaylistItem.m
//   
//
//  Created by liweizhao on 2018/4/21.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZPlaylistItem.h"

@implementation JZPlaylistItem

- (JZNowPlayingInfoModel *)infoModel {
    
    if (!_infoModel) {
        _infoModel = JZNowPlayingInfoModel.alloc.init;
    }
    
    return _infoModel;
}

@end
