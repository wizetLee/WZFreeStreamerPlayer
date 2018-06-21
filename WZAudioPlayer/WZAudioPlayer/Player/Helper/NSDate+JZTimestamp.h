//
//  NSData+JZTimestamp.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/16.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JZTimestamp)

///秒->音频/视频的时长
+ (NSString *)getMMSSFromSS:(NSInteger)seconds;

///时间戳->最近（秒、分、时、天）
+ (NSString *)getTimeWithTimestamp:(NSString *)timestamp;


@end
