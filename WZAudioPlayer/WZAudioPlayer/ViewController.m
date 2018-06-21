//
//  ViewController.m
//  WZAudioPlayer
//
//  Created by liweizhao on 2018/5/26.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "ViewController.h"
#import "JZFMDetailViewController.h"
#import "JZAudioPlayerManager.h"
#import "JZFMAudioListModel.h"
 
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioData" ofType:@"plist"];
    NSMutableArray <NSDictionary *>*audioInfosList = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    NSMutableArray *tmp = [NSMutableArray array];
    [audioInfosList  enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JZFMAudioListModel *model = JZFMAudioListModel.new;
        model.url = obj[@"audioUrl"];
        model.logoUrl = obj[@"audioImage"];
        model.name = obj[@"audioName"];
        [tmp addObject:model];
        if (!model.url) {
            model.url = @"自定义错误";
        }
    }];
    
    [[JZAudioPlayerManager sharedInstance] setPlaylist:tmp];
}

- (IBAction)play:(id)sender {
    [[JZAudioPlayerManager sharedInstance] playWithIndex:0];
    [self presentViewController:[JZFMDetailViewController new] animated:true completion:^{}];
}




@end
