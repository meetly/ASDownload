//
//  ASSession.h
//  DownLoad
//
//  Created by share on 2017/11/13.
//  Copyright © 2017年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 下载状态 */
typedef NS_ENUM(NSInteger, ASDownloadState) {
    /** 没有该任务 */
    ASDownloadStateNoTask = 0,
    /** 等待下载 */
    ASDownloadStateWaiting,
    /** 下载中 */
    ASDownloadStateLoading,
    /** 下载暂停 */
    ASDownloadStatePause,
    /** 下载完成 */
    ASDownloadStateCompleted,
    /** 下载失败 */
    ASDownloadStateFailed,
};
/**
 下载中的回调

 @param progress 进度
 @param speed 速度
 @param remainingTime 剩余时间
 @param writtenSize 写入大小
 @param totalSize 总大小
 */
typedef void(^ASDownloadingBlock)(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize);

/**
 下载状态的回调

 @param state 下载状态
 */
typedef void(^ASDownloadStateBlock)(ASDownloadState state);

@interface ASSession : NSObject <NSCoding>

/** 下载地址 */
@property (nonatomic, copy) NSString *url;

/** 开始下载时间 */
@property (nonatomic, strong) NSDate *startTime;

/** 文件名 */
@property (nonatomic, copy) NSString *fileName;

/** 文件总大小 */
@property (nonatomic, copy) NSString *totalSize;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 已下载大小 */
@property (nonatomic, copy) NSString *totalBytesWritten;

/** 进度 */
@property (nonatomic, assign) float progress;

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
/** 创建流 */
@property (nonatomic, strong) NSOutputStream *stream;
/**  下载状态 */
@property (nonatomic, assign) ASDownloadState downloadState;
/** 下载进度 */
@property (atomic, copy) ASDownloadingBlock downloadingBlock;

/** 下载状态 */
@property (atomic, copy) ASDownloadStateBlock stateBlock;

@end
