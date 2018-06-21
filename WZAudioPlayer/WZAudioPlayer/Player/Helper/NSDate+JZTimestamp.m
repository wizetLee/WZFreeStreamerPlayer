//
//  NSData+JZTimestamp.m
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/16.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import "NSDate+JZTimestamp.h"



@implementation NSDate (JZTimestamp)


+ (NSString *)getMMSSFromSS:(NSInteger)seconds {
    NSString *str_minute = nil;
    NSString *str_second = nil;
//    if (seconds / 60 < 10.0) {
//        str_minute = [NSString stringWithFormat:@"0%ld", seconds / 60];
//    } else {
//        str_minute = [NSString stringWithFormat:@"%ld", seconds / 60];
//    }
//
    str_minute = [NSString stringWithFormat:@"%ld", seconds / 60];
    if (seconds % 60 < 10) {
        str_second = [NSString stringWithFormat:@"0%ld", seconds % 60];
    } else {
        str_second = [NSString stringWithFormat:@"%ld", seconds % 60];
    }
    
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}


+ (NSString *)getTimeWithTimestamp:(NSString *)timestamp {
    if (!timestamp) {
        return @"";
    }
    
    double timestampValue  = [timestamp doubleValue];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:timestampValue];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];//获取本设备时区
    NSInteger interval = [zone secondsFromGMTForDate:timeDate];//计算本设备时区与格林威治时区的时间偏差
    
    NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];//参数提供的时间
    NSDate *nowDate = [[NSDate date] dateByAddingTimeInterval:interval];//当前时间

    NSString *time = @"";

    if ([[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:mydate] day] == [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:nowDate] day]) {
        time = @"今天";
    } else {
        NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
        dataformatter.dateFormat = @"yyyy-MM-dd";
        time = [dataformatter stringFromDate:mydate];
    }
    return time;
}

@end
