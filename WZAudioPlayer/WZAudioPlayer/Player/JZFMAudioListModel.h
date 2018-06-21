//
//  JZFMAudioListModel.h
//  iPhoneStock
//
//  Created by liweizhao on 2018/5/6.
//  Copyright © 2018年 com.jingzhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JZFMAudioListModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *logoUrl;

@property (nonatomic, strong) NSMutableAttributedString *nameAtr;
@property (nonatomic, assign) CGFloat nameAtrHeight;

@end
