//
//  ASDownloadManger.m
//  DownLoad
//
//  Created by share on 2017/11/13.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASDownloadManger.h"


@interface ASDownloadManger () <NSURLSessionDelegate, NSURLSessionDataDelegate>
/**  最大下载数 */
@property (nonatomic, assign) NSInteger maximumConnections;
/**  全部任务 */
@property (nonatomic, strong) NSArray *allDownloadArr;
/**  下载完成的任务 */
@property (nonatomic, strong) NSMutableArray *downloadedArr;
/**  下载中的任务 (包括 等待、暂停、失败、下载中)*/
@property (nonatomic, strong) NSMutableArray *downloadingArr;
/**  正在处理的任务  */
@property (nonatomic, strong) NSMutableArray *performingArr;
/**  等待处理的任务  */
@property (nonatomic, strong) NSMutableArray *performWaitArr;
/**  是否添加过监听 */
@property (nonatomic, assign) BOOL isAddNotification;
@end

@implementation ASDownloadManger

#pragma mark ---------  创建单例 ---------------
static ASDownloadManger* _instance = nil;
+(instancetype)sharedInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+(id)allocWithZone:(struct _NSZone *)zone {
    return [ASDownloadManger sharedInstance];
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return [ASDownloadManger sharedInstance];
}

#pragma mark ----------- 外部调用方法实现 -----------
- (ASDownloadTaskState)download:(NSString *)url progress:(ASDownloadingBlock)progressBlock state:(ASDownloadStateBlock)stateBlock {

    //添加程序杀死监听
    if (!self.isAddNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        self.isAddNotification = YES;
    }
    //检查该url可否下载
    if ([self CheckCanDownload:url] != ASDownloadTaskStateCanDownload) {
        return [self CheckCanDownload:url];
    }
    //创建缓存目录文件
    [self createCacheDirectory];
    
    //开始任务
    NSArray *sessionArr = [self resumeURLSession:url];

    //数据
    ASSession *session = [[ASSession alloc] init];
    session.url = url;
    if(progressBlock) session.downloadingBlock  = progressBlock;
    if(stateBlock) session.stateBlock = stateBlock;
    session.downloadState = ASDownloadStateWaiting;
    if (session.stateBlock) session.stateBlock(ASDownloadStateWaiting);
    session.dataTask = sessionArr.firstObject;
    session.stream = sessionArr.lastObject;
    [self addSession:session];
    
    //开始任务或等待下载
    if ([self startOrWaitDownload:session]) [session.dataTask resume];
    
    return ASDownloadTaskStateCanDownload;
}

- (void)setMaximumConnection:(NSInteger)maximumConnections {
    if (maximumConnections) {
        self.maximumConnections = maximumConnections;
    }
}
- (void)resumeDownload:(NSString *)url {
    //添加程序杀死监听
    if (!self.isAddNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        self.isAddNotification = YES;
    }
    ASSession *session = [self getDownloadingSessionWithUrl:url];
    if (!session) return;
    if (session.downloadState==ASDownloadStatePause || session.downloadState==ASDownloadStateFailed) {
        if (session.dataTask) {
            //开始任务或等待下载
            if ([self startOrWaitDownload:session]) [session.dataTask resume];
        }else {
            NSArray *sessionArr = [self resumeURLSession:session.url];
            session.dataTask = sessionArr.firstObject;
            session.stream = sessionArr.lastObject;
            //开始任务或等待下载
            if ([self startOrWaitDownload:session]) [session.dataTask resume];
            [self saveSessions];
        }
        
    }
}

- (void)pauseDownload:(NSString *)url {
    ASSession *session = [self getDownloadingSessionWithUrl:url];
    if (session.dataTask) {
        if (session.downloadState == ASDownloadStateLoading) {
            [session.dataTask suspend];
            session.downloadState = ASDownloadStatePause;
            if (session.stateBlock) session.stateBlock(ASDownloadStatePause);
            //正在处理任务中移除
            [self removeObjectWith:self.performingArr session:session];

        }
    }
    [self saveSessions];

}

- (ASSession *)getDownloadSessionWithUrl:(NSString *)url {
    for (NSArray *array in self.allDownloadArr) {
        for (NSDictionary *dic in array) {
            if ([dic objectForKey:url]) return [dic objectForKey:url];
        }
    }
    return nil;
}
- (ASDownloadState)getDownloadStateWithUrl:(NSString *)url {
    ASSession *session = [self getDownloadSessionWithUrl:url];
    if (session)  return session.downloadState;
    return ASDownloadStateNoTask;
}
- (NSArray *)getDownloadedArr {
    NSMutableArray *downArr = [NSMutableArray array];
    for (NSDictionary *dic in self.downloadedArr) {
        for (NSString *keyStr in dic.allKeys) {
            ASSession *session = [dic objectForKey:keyStr];
            [downArr addObject:session];
        }
    }
    return downArr;
}

- (NSArray *)getDownloadingArr {
    NSMutableArray *downArr = [NSMutableArray array];
    for (NSDictionary *dic in self.downloadingArr) {
        for (NSString *keyStr in dic.allKeys) {
            ASSession *session = [dic objectForKey:keyStr];
            [downArr addObject:session];
        }
    }
    return downArr;
}
- (void)deleteDownloadTask:(NSString *)url {
    ASSession *session = [self getDownloadSessionWithUrl:url];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //从对应数组中清楚
    if (session && session.downloadState == ASDownloadStateCompleted) {
        if ([self.downloadedArr containsObject:@{session.url:session}]) {
            //移除数组中信息
            [self.downloadedArr removeObject:@{session.url:session}];
            if ([fileManager fileExistsAtPath:ASFileFullpath(url)]) {
                // 删除沙盒中的资源
                [fileManager removeItemAtPath:ASFileFullpath(url) error:nil];
            }
        }
    }else {
        if ([self.downloadingArr containsObject:@{session.url:session}]) {
            [session.stream close];
            session.stream = nil;
            //移除数组中信息
            [self.downloadingArr removeObject:@{session.url:session}];
            if ([fileManager fileExistsAtPath:ASFileFullpath(url)]) {
                // 删除沙盒中的资源
                [fileManager removeItemAtPath:ASFileFullpath(url) error:nil];
            }
        }
    }
    //删除正在下载和等待下载的数组
    [self removeObjectWith:self.performWaitArr session:session];
    [self removeObjectWith:self.performingArr session:session];
    //开始下一个任务
    if (session.downloadState == ASDownloadStateLoading) [self startNextDownload];
    [self saveSessions];
}
- (void)deleteAllDownloadTask {
    //关闭下载任务的流
    for (NSDictionary *dic in self.downloadingArr) {
        for (NSString *url in dic.allKeys) {
            if (url){
                ASSession *session = [dic objectForKey:url];
                [session.stream close];
                session.stream = nil;
            }
        }
    }
    [self.downloadingArr removeAllObjects];
    [self.downloadedArr removeAllObjects];
    [self saveSessions];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ASCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:ASCachesDirectory error:nil];
    }
    if ([fileManager fileExistsAtPath:ASDownloadDetailPath]) {
        // 删除沙盒中数据源
        [fileManager removeItemAtPath:ASDownloadDetailPath error:nil];
    }
    [self.performWaitArr removeAllObjects];
    [self.performingArr removeAllObjects];
}

#pragma mark ------------ 内部处理方法 -----------------
/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ASCachesDirectory]) {
        [fileManager createDirectoryAtPath:ASCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}


/**
 task的urlString

 @param task 任务
 @return urlString
 */
- (NSString *)urlStringWithTastResponse:(NSURLSessionTask *)task {
    return [task.response.URL absoluteString];
}

/**
 配置任务

 @param url 任务地址
 @return @[NSURLSessionDataTask, session]
 */
- (NSArray *)resumeURLSession:(NSString *)url {
    // session配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 得到session对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:ASFileFullpath(url) append:YES];
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", ASDownloadLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    // 创建一个Data任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    return @[dataTask, stream];
}

/**
 * 存储信息
 */
- (void)saveSessions
{
    self.allDownloadArr = @[self.downloadedArr, self.downloadingArr];
    [NSKeyedArchiver archiveRootObject:self.allDownloadArr toFile:ASDownloadDetailPath];
}

/**
 * 读取信息
 */
- (NSArray *)getSessions
{
    // 文件信息
    NSArray *downloadArr = [NSKeyedUnarchiver unarchiveObjectWithFile:ASDownloadDetailPath];
    return downloadArr;
}

/**
 添加信息到本地

 @param session 信息
 */
- (void)addSession:(ASSession *)session {
    [self.downloadingArr addObject:@{session.url:session}];
    [self saveSessions];
}

/**
 根据url获取正在下载session

 @param url 下载地址
 */
- (ASSession *)getDownloadingSessionWithUrl:(NSString *)url {
    for (NSDictionary *dic in self.downloadingArr) {
        if ([dic objectForKey:url]){
           return [dic objectForKey:url];
        }
    }
    return nil;
}
/**
 根据url获取已下载session
 
 @param url 下载地址
 */
- (ASSession *)getDownloadedSessionWithUrl:(NSString *)url {
    for (NSDictionary *dic in self.downloadedArr) {
        if ([dic objectForKey:url]) return [dic objectForKey:url];
    }
    return nil;
}

/**
 计算指定字节大小

 @param contentLength 需要计算的长度
 @return 大小
 */
- (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3)) { return (float) (contentLength / (float)pow(1024, 3)); }
    else if (contentLength >= pow(1024, 2)) { return (float) (contentLength / (float)pow(1024, 2)); }
    else if (contentLength >= 1024) { return (float) (contentLength / (float)1024); }
    else { return (float) (contentLength); }
}

/**
 计算指定字节单位

 @param contentLength 需要计算的长度
 @return 单位
 */
- (NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3)) { return @"GB";}
    else if(contentLength >= pow(1024, 2)) { return @"MB"; }
    else if(contentLength >= 1024) { return @"KB"; }
    else { return @"B"; }
}

/**
 是否可以下载任务

 @param url 下载url
 @return 任务状态
 */
- (ASDownloadTaskState)CheckCanDownload:(NSString *)url {
    //url为空
    if (!url) return ASDownloadTaskStateUrlNil;
    //正确的url
    if (![self rightUrl:url]) return ASDownloadTaskStateUrlRrror;
    
    if (![self getDownloadSessionWithUrl:url]) return ASDownloadTaskStateCanDownload;
    //任务状态
    ASSession *session =  [self getDownloadSessionWithUrl:url];
    switch (session.downloadState) {
        case ASDownloadStateWaiting:
            return ASDownloadTaskStateWaiting;
        case ASDownloadStateLoading:
            return ASDownloadTaskStateLoading;
        case ASDownloadStatePause:
            return ASDownloadTaskStatePause;
        case ASDownloadStateFailed:
            return ASDownloadTaskStateFailed;
        case ASDownloadStateCompleted:
            return ASDownloadTaskStateCompleted;
        default:
            return ASDownloadTaskStateNoTask;
    }
}

/**
 匹配正确网址

 @param string 需要验证的字符串
 @return 是否是正确网址
 */
- (BOOL)rightUrl:(NSString *)string {
    
    NSString *regex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}
//双击home杀死
/**
 杀死进程

 @param application application
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    for (NSDictionary *dic in self.downloadingArr) {
        for (NSString *keyStr in dic.allKeys) {
            ASSession *session = [dic objectForKey:keyStr];
            [self pauseDownload:session.url];
        }
    }
}

/**
 url对应任务是否下载完成

 @param url 下载地址
 */
- (BOOL)downloadIsComplete:(NSString *)url {
    ASSession *session = [self getDownloadSessionWithUrl:url];
    if (session.totalLength == ASDownloadLength(url)) return YES;
    return NO;
}


/**
 开始任务或者等待开始

 @return 是否立即开始任务
 */
- (BOOL)startOrWaitDownload:(ASSession *)session {
    //没有限制直接下载
    if (!self.maximumConnections) {[self.performingArr addObject:session]; return YES; }
    //立即下载
    if (self.performingArr.count<self.maximumConnections) {
        [self addObjectWith:self.performingArr session:session];;
        return YES;
    } else {//等待下载
        session.downloadState = ASDownloadStateWaiting;
        if (session.stateBlock) session.stateBlock(ASDownloadStateWaiting);
        [self addObjectWith:self.performWaitArr session:session];;
        return NO;
    }
}

/**
 开始下一个任务
 */
- (void)startNextDownload {
    ASSession *session = self.performWaitArr.firstObject;
    if (session && session.dataTask) [session.dataTask resume];
    [self removeObjectWith:self.performWaitArr session:session];
}

/**
 数组中删除任务

 @param array 数组
 */
- (void)removeObjectWith:(NSMutableArray *)array session:(ASSession *)session {
    for (ASSession *arrSession in array.reverseObjectEnumerator) {
        if (arrSession.url == session.url) {
            [array removeObject:arrSession];
        }
    }
}
/**
 数组中添加任务
 
 @param array 数组
 */
- (void)addObjectWith:(NSMutableArray *)array session:(ASSession *)session {
    for (ASSession *arrSession in array) {
        if (arrSession.url == session.url) {
            return;
        }
    }
    [array addObject:session];
}
#pragma mark ------------- NSURLSessionDataDelegate ------------

/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    ASSession * asSession = [self getDownloadingSessionWithUrl:[self urlStringWithTastResponse:dataTask]];
    asSession.startTime = [NSDate date];
    // 打开流
    [asSession.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + ASDownloadLength(asSession.url);
    asSession.totalLength = totalLength;
    //总大小
    float totalSize = [self calculateFileSizeInUnit:(unsigned long long)totalLength];
    NSString *totalUnit = [self calculateUnit:(unsigned long long)totalLength];
    NSString *totalStr = [NSString stringWithFormat:@"%.2f%@",totalSize,totalUnit];
    asSession.totalSize = totalStr;

    // 更新数据(文件总长度)
    [self saveSessions];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    ASSession * asSession = [self getDownloadingSessionWithUrl:[self urlStringWithTastResponse:dataTask]];
    //文件名
    asSession.fileName = dataTask.response.suggestedFilename;
    
    // 写入数据
    [asSession.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = ASDownloadLength(asSession.url);
    NSUInteger expectedSize = asSession.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    asSession.progress = progress;
    
    //已写入大小
    float totalBytesWrittenSize = [self calculateFileSizeInUnit:(unsigned long long)receivedSize];
    NSString *totalBytesWrittenUnit = [self calculateUnit:(unsigned long long)receivedSize];
    NSString *totalBytesWrittenStr = [NSString stringWithFormat:@"%.2f%@",totalBytesWrittenSize,totalBytesWrittenUnit];
    asSession.totalBytesWritten = totalBytesWrittenStr;
    
    // 每秒下载速度
    NSTimeInterval downloadTime = -1 * [asSession.startTime timeIntervalSinceNow];
    NSUInteger speed = receivedSize / downloadTime;
    if (speed == 0) { return; }
    float speedSize = [self calculateFileSizeInUnit:(unsigned long long)speed];
    NSString *speedUnit = [self calculateUnit:(unsigned long long)speed];
    NSString *speedStr = [NSString stringWithFormat:@"%.2f%@/S",speedSize,speedUnit];
    
    // 剩余下载时间
    NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
    unsigned long long remainingContentLength = expectedSize - receivedSize;
    int remainingTime = (int)(remainingContentLength / speed);
    
    int hours = remainingTime / 3600;
    int minutes = (remainingTime - hours * 3600) / 60;
    int seconds = remainingTime - hours * 3600 - minutes * 60;
    
    if(hours>0) {[remainingTimeStr appendFormat:@"%d 小时 ",hours];}
    if(minutes>0) {[remainingTimeStr appendFormat:@"%d 分 ",minutes];}
    if(seconds>0) {[remainingTimeStr appendFormat:@"%d 秒",seconds];}
    
    asSession.downloadState = ASDownloadStateLoading;
    if (asSession.stateBlock) asSession.stateBlock(ASDownloadStateLoading);
    //回调信息
    if (asSession.downloadingBlock) asSession.downloadingBlock((double)progress, speedStr, remainingTimeStr, totalBytesWrittenStr, asSession.totalSize);
    [self saveSessions];

}

/**
 *  下载完毕会调用 (成功失败)
 *
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    ASSession * asSession = [self getDownloadingSessionWithUrl:[self urlStringWithTastResponse:task]];
    // 关闭流
    [asSession.stream close];
    asSession.stream = nil;
    
    //下载完成
    if ([self downloadIsComplete:asSession.url]) {
        [self.downloadedArr addObject:@{asSession.url:asSession}];
        [self.downloadingArr removeObject:@{asSession.url:asSession}];
        asSession.downloadState = ASDownloadStateCompleted;
        if (asSession.stateBlock) asSession.stateBlock(ASDownloadStateCompleted);
        [self saveSessions];

    } else {
        //下载失败
        if (error) { //error.code == -999  cancel
            NSString *url = [NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"NSErrorFailingURLKey"]];
            ASSession * asSession = [self getDownloadingSessionWithUrl:url];
            //暂停状态有时会走到失败里
            if (asSession.downloadState == ASDownloadStateWaiting || asSession.downloadState == ASDownloadStatePause) return;
            asSession.downloadState = ASDownloadStateFailed;
            if (asSession.stateBlock) asSession.stateBlock(ASDownloadStateFailed);
        }
        [self saveSessions];
    }
    
    //正在处理任务中移除
    [self removeObjectWith:self.performingArr session:asSession];
    //开始下一个任务
    [self startNextDownload];
    
    
}


#pragma mark -------------  懒加载 -----------------
- (NSArray *)allDownloadArr {
    if (!_allDownloadArr) {
        if ([self getSessions]) {
            _allDownloadArr = [self getSessions];
        } else {
            _allDownloadArr = [NSArray array];
        }
    }
    return _allDownloadArr;
}
- (NSMutableArray *)downloadedArr {
    if (!_downloadedArr) {
        if (self.allDownloadArr.firstObject) {
            _downloadedArr = self.allDownloadArr.firstObject;
        }else {
            _downloadedArr = [NSMutableArray array];
        }
    }
    return _downloadedArr;
}
- (NSMutableArray *)downloadingArr {
    if (!_downloadingArr) {
        if (self.allDownloadArr.lastObject) {
            _downloadingArr = self.allDownloadArr.lastObject;
        }else {
            _downloadingArr = [NSMutableArray array];
        }
        
    }
    return _downloadingArr;
}
- (NSMutableArray *)performingArr {
    if (!_performingArr) {
        _performingArr = [NSMutableArray array];
    }
    return _performingArr;
}
- (NSMutableArray *)performWaitArr {
    if (!_performWaitArr) {
        _performWaitArr = [NSMutableArray array];
    }
    return _performWaitArr;
}

@end
