# ASDownload
功能更全面的下载器
## 特点 <br>
* 控制同时下载任务数量
* 支持断点下载
* 退出保留下载进度，任可继续下载
* 回调下载进度、下载速度、剩余时间
* 使用block进行回调信息
## 主要功能介绍 <br>

```
/**
 开启下载任务

 @param url 下载地址
 @param progressBlock 进度回调
 @param stateBlock 状态回调
 */
- (ASDownloadTaskState)download:(NSString *)url progress:(ASDownloadingBlock)progressBlock state:(ASDownloadStateBlock)stateBlock;
```
```
/**
 同时下载任务数量
 超过最大下载数，任务会等待下载，并依次执行，但是杀死程序后，这些等待的任务将不会依次下载，需要手动调用恢复下载方法
 @param maximumConnections 数量(默认没有限制)
 */
- (void)setMaximumConnection:(NSInteger)maximumConnections;
```
```
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
```
```
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
```
```
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
```

## 使用方法<br>
```
//设置同时下载任务数量 默认不限制
[[ASDownloadManger sharedInstance] setMaximumConnection:1];

//state 返回任务是否可下载 以及不可下载原因
//progress 下载进度回调
//state   下载状态回调
 ASDownloadTaskState state = [[ASDownloadManger sharedInstance] download:url progress:nil state:nil];
    switch (state) {
        case ASDownloadTaskStateUrlNil:
            //下载地址为空
            break;
        case ASDownloadTaskStateUrlRrror:
            //下载地址错误
            break;
        case ASDownloadTaskStateCompleted:
            //此任务已下载完成
            break;
        case ASDownloadTaskStateCanDownload:
            //可下载
            break;
        default:
            break;
    }
```
## 联系我
```
*  QQ:469091701
*  e-mail:meet_ly@163.com
```
# 更详细的使用 请参考DEMO，希望能帮助到大家
