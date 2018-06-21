//
//  JZFMAudioListModel.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/6.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "JZFMAudioListModel.h"
#import "NSDate+JZTimestamp.h"

@implementation JZFMAudioListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"name"                : @"name",
             @"url"                 : @"url",
             @"duration"            : @"duration",
             @"logoUrl"             : @"logo_url",
             };
    
}

@end
