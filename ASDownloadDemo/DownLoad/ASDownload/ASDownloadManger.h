//
//  ASDownloadManger.h
//  DownLoad
//
//  Created by share on 2017/11/13.
//  Copyright © 2017年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASSession.h"

// 缓存主目录(caches)
#define ASCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"ASCache"]

// 文件格式后缀(mp3, mp4, .....)
#define ASFileName(url)  [[url componentsSeparatedByString:@"/"] lastObject]

// 文件的存放路径
#define ASFileFullpath(url) [ASCachesDirectory stringByAppendingPathComponent:ASFileName(url)]

// 文件的已下载长度
#define ASDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:ASFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件信息的路径（caches）
#define ASDownloadDetailPath [ASCachesDirectory stringByAppendingPathComponent:@"ASData.data"]

/** 下载任务时该任务对应的状态 ： 是否可以下载为什么不能下载*/
typedef NS_ENUM(NSInteger, ASDownloadTaskState) {
    /** url为空 */
    ASDownloadTaskStateUrlNil = 0,
    /** url格式不正确 */
    ASDownloadTaskStateUrlRrror ,
    /** 等待下载 */
    ASDownloadTaskStateWaiting,
    /** 下载中 */
    ASDownloadTaskStateLoading,
    /** 下载暂停 */
    ASDownloadTaskStatePause,
    /** 下载完成 */
    ASDownloadTaskStateCompleted,
    /** 下载失败 */
    ASDownloadTaskStateFailed,
    /** 没有这个任务 */
    ASDownloadTaskStateNoTask,
    /** 可以下载  */
    ASDownloadTaskStateCanDownload
};

@interface ASDownloadManger : NSObject
/**
 *  单例
 *
 *  @return 返回单例对象
 */
+ (instancetype)sharedInstance;


/**
 同时下载任务数量
 超过最大下载数，任务会等待下载，并依次执行，但是杀死程序后，这些等待的任务将不会依次下载，需要手动调用恢复下载方法
 @param maximumConnections 数量(默认没有限制)
 */
- (void)setMaximumConnection:(NSInteger)maximumConnections;

/**
 开启下载任务

 @param url 下载地址
 @param progressBlock 进度回调
 @param stateBlock 状态回调
 */
- (ASDownloadTaskState)download:(NSString *)url progress:(ASDownloadingBlock)progressBlock state:(ASDownloadStateBlock)stateBlock;

/**
 恢复下载任务 (不可用于创建任务。暂停、失败和等待中的任务可以调用 )
 
 @param url 任务的下载地址
 */
- (void)resumeDownload:(NSString *)url;

/**
 暂停下载任务

 @param url 任务的下载地址
 */
- (void)pauseDownload:(NSString *)url;

/**
 根据url获取下载session
 
 @param url 下载地址
 */
- (ASSession *)getDownloadSessionWithUrl:(NSString *)url;
/**
 根据url获取下载状态
 @param url 下载地址
 */
- (ASDownloadState)getDownloadStateWithUrl:(NSString *)url;

/**
 获取下载完成数组

 @return 数组
 */
- (NSArray *)getDownloadedArr;
/**
 获取下载完成数组
 
 @return 数组
 */
- (NSArray *)getDownloadingArr;

/**
 删除对应url任务

 @param url 下载地址
 */
- (void)deleteDownloadTask:(NSString *)url;

/**
 清空所有下载任务 (下载中和下载完成都会清空)
 */
- (void)deleteAllDownloadTask;
@end
