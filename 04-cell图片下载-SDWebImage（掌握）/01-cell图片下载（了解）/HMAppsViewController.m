//
//  HMAppsViewController.m
//  01-cell图片下载（了解）
//
//  Created by apple on 14-9-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMAppsViewController.h"
#import "HMApp.h"
#import "UIImageView+WebCache.h"

@interface HMAppsViewController ()
/**
 *  所有的应用数据
 */
@property (nonatomic, strong) NSMutableArray *apps;
@end

@implementation HMAppsViewController

#pragma mark - 懒加载
- (NSMutableArray *)apps
{
    if (!_apps) {
        // 1.加载plist
        NSString *file = [[NSBundle mainBundle] pathForResource:@"apps" ofType:@"plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
        
        // 2.字典 --> 模型
        NSMutableArray *appArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            HMApp *app = [HMApp appWithDict:dict];
            [appArray addObject:app];
        }
        
        // 3.赋值
        self.apps = appArray;
//        _apps = appArray;
    }
    return _apps;
}

#pragma mark - 初始化方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"app";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 取出模型
    HMApp *app = self.apps[indexPath.row];
    
    // 设置基本信息
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    
    // 下载图片
    NSURL *url = [NSURL URLWithString:app.icon];
    UIImage *placeholder = [UIImage imageNamed:@"placeholder"];
//    [cell.imageView sd_setImageWithURL:url placeholderImage:placeholder];
    
//    [cell.imageView sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"----图片加载完毕---%@", image);
//    }];
    
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    [cell.imageView sd_setImageWithURL:url placeholderImage:placeholder options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) { // 这个block可能会被调用多次
        NSLog(@"下载进度：%f", (double)receivedSize / expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"----图片加载完毕---%@", image);
    }];
    return cell;
}
@end
