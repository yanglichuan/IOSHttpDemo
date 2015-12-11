//
//  HMAppsViewController.m
//  01-cell图片下载（了解）
//
//  Created by apple on 14-9-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#define HMAppImageFile(url) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[url lastPathComponent]]

#import "HMAppsViewController.h"
#import "HMApp.h"

@interface HMAppsViewController ()
/**
 *  所有的应用数据
 */
@property (nonatomic, strong) NSMutableArray *apps;

/**
 *  存放所有下载操作的队列
 */
@property (nonatomic, strong) NSOperationQueue *queue;

/**
 *  存放所有的下载操作（url是key，operation对象是value）
 */
@property (nonatomic, strong) NSMutableDictionary *operations;

/**
 *  存放所有下载完的图片
 */
@property (nonatomic, strong) NSMutableDictionary *images;
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

- (NSOperationQueue *)queue
{
    if (!_queue) {
        self.queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSMutableDictionary *)operations
{
    if (!_operations) {
        self.operations = [[NSMutableDictionary alloc] init];
    }
    return _operations;
}

- (NSMutableDictionary *)images
{
    if (!_images) {
        self.images = [[NSMutableDictionary alloc] init];
    }
    return _images;
}

#pragma mark - 初始化方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 这里仅仅是block对self进行了引用，self对block没有任何引用
    [UIView animateWithDuration:2.0 animations:^{
        self.view.frame = CGRectMake(0, 0, 100, 100);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // 移除所有的下载操作缓存
    [self.queue cancelAllOperations];
    [self.operations removeAllObjects];
    // 移除所有的图片缓存
    [self.images removeAllObjects];
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
    
    // 先从images缓存中取出图片url对应的UIImage
    UIImage *image = self.images[app.icon];
    if (image) { // 说明图片已经下载成功过（成功缓存）
        cell.imageView.image = image;
    } else { // 说明图片并未下载成功过（并未缓存过）
        // 获得caches的路径, 拼接文件路径
        NSString *file = HMAppImageFile(app.icon);
        
        // 先从沙盒中取出图片
        NSData *data = [NSData dataWithContentsOfFile:file];
        if (data) { // 沙盒中存在这个文件
            cell.imageView.image = [UIImage imageWithData:data];
        } else { // 沙盒中不存在这个文件
            // 显示占位图片
            cell.imageView.image = [UIImage imageNamed:@"placeholder"];
            
            // 下载图片
            [self download:app.icon indexPath:indexPath];
        }
    }
    
    return cell;
}

/**
 *  下载图片
 *
 *  @param imageUrl 图片的url
 */
- (void)download:(NSString *)imageUrl indexPath:(NSIndexPath *)indexPath
{
    // 取出当前图片url对应的下载操作（operation对象）
    NSBlockOperation *operation = self.operations[imageUrl];
    if (operation) return;
    
    // 创建操作，下载图片
    __weak typeof(self) appsVc = self;
    operation = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url]; // 下载
        UIImage *image = [UIImage imageWithData:data]; // NSData -> UIImage
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 存放图片到字典中
            if (image) {
                appsVc.images[imageUrl] = image;
                
#warning 将图片存入沙盒中
                // UIImage --> NSData --> File（文件）
                NSData *data = UIImagePNGRepresentation(image);
                
                // 获得caches的路径, 拼接文件路径
//                NSString *file = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[imageUrl lastPathComponent]];
                
                [data writeToFile:HMAppImageFile(imageUrl) atomically:YES];
//                UIImageJPEGRepresentation(<#UIImage *image#>, 1.0)
            }
            
            // 从字典中移除下载操作 (防止operations越来越大，保证下载失败后，能重新下载)
            [appsVc.operations removeObjectForKey:imageUrl];
            
            // 刷新表格
            [appsVc.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
    
    // 添加操作到队列中
    [self.queue addOperation:operation];
    
    // 添加到字典中 (这句代码为了解决重复下载)
    self.operations[imageUrl] = operation;
}

/**
 *  当用户开始拖拽表格时调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 暂停下载
    [self.queue setSuspended:YES];
}

/**
 *  当用户停止拖拽表格时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 恢复下载
    [self.queue setSuspended:NO];
}

@end
