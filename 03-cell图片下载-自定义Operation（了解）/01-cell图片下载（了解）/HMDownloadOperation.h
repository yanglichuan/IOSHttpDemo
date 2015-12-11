//
//  HMDownloadOperation.h
//  01-cell图片下载（了解）
//
//  Created by apple on 14-9-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMDownloadOperation;

@protocol HMDownloadOperationDelegate <NSObject>
@optional
- (void)downloadOperation:(HMDownloadOperation *)operation didFinishDownload:(UIImage *)image;
@end

@interface HMDownloadOperation : NSOperation
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<HMDownloadOperationDelegate> delegate;
@end
