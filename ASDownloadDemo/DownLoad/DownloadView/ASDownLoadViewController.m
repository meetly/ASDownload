//
//  ASDownLoadViewController.m
//  DownLoad
//
//  Created by share on 2017/11/16.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASDownLoadViewController.h"
#import "ASListViewController.h"
#import "ASDownloadTableViewCell.h"
#import "ASDownloadManger.h"
@interface ASDownLoadViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *downloadedArr;
@property (nonatomic, strong) NSMutableArray *downloadingArr;

@end

@implementation ASDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载列表";
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self updateData];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, SCREEN_WIDTH, SCREEN_HEIGHT-navHeight)style:(UITableViewStyleGrouped)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    

}
- (void)updateData {
    self.downloadedArr = [[ASDownloadManger sharedInstance] getDownloadedArr].mutableCopy;
    self.downloadingArr = [[ASDownloadManger sharedInstance] getDownloadingArr].mutableCopy;
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.downloadedArr.count;
    }else {
        return self.downloadingArr.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block ASDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ASDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.section == 0) {
        ASSession *session = self.downloadedArr[indexPath.row];
        cell.nameLabel.text = session.url;
        cell.speedLabel.text = @"完成";
        cell.stateLabbel.text = @"";
        cell.progressView.progress = 1;
        cell.sizeLabel.text = session.totalSize;
    }else {
        ASSession *session = self.downloadingArr[indexPath.row];
        if (session.url) cell.nameLabel.text = session.url;
        if (session.totalSize&&session.totalBytesWritten) cell.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",session.totalBytesWritten,session.totalSize];
        if (session.progress) cell.progressView.progress = session.progress;
        if (session.downloadState) {
            switch (session.downloadState) {
                case ASDownloadStatePause:
                    cell.stateLabbel.text = @"暂停";
                    break;
                case ASDownloadStateLoading:
                    cell.stateLabbel.text = @"正在下载";
                    break;
                case ASDownloadStateFailed:
                    cell.stateLabbel.text = @"失败";
                    break;
                case ASDownloadStateWaiting:
                    cell.stateLabbel.text = @"等待下载";
                    break;
                case ASDownloadStateCompleted:
                    [self updateData];
                    break;
                default:
                    break;
            }
        }
        
        session.downloadingBlock = ^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
            cell.speedLabel.text = speed;
            cell.progressView.progress = progress;
            cell.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",writtenSize,totalSize];
        };
        session.stateBlock = ^(ASDownloadState state) {
            switch (state) {
                case ASDownloadStatePause:
                    cell.stateLabbel.text = @"暂停";
                    break;
                case ASDownloadStateLoading:
                    cell.stateLabbel.text = @"正在下载";
                    break;
                case ASDownloadStateFailed:
                    cell.speedLabel.text = @"";
                    cell.stateLabbel.text = @"失败";
                    break;
                case ASDownloadStateCompleted:
                    [self updateData];
                    break;
                case ASDownloadStateWaiting:
                    cell.stateLabbel.text = @"等待下载";
                    break;
                default:
                    break;
            }
        };

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        headerLab.textAlignment = NSTextAlignmentLeft;
        headerLab.textColor = [UIColor lightGrayColor];
        headerLab.font = [UIFont systemFontOfSize:15];
        headerLab.text = @"下载完成";
        return headerLab;
    }else {
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        headerLab.textAlignment = NSTextAlignmentLeft;
        headerLab.textColor = [UIColor lightGrayColor];
        headerLab.font = [UIFont systemFontOfSize:15];
        headerLab.text = @"正在下载";
        return headerLab;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        ASSession *session = self.downloadingArr[indexPath.row];
        switch (session.downloadState) {
            case ASDownloadStatePause:
                [[ASDownloadManger sharedInstance] resumeDownload:session.url];
                break;
            case ASDownloadStateLoading:
                [[ASDownloadManger sharedInstance] pauseDownload:session.url];
                break;
            case ASDownloadStateFailed:
                [[ASDownloadManger sharedInstance] resumeDownload:session.url];
                break;
            case ASDownloadStateWaiting:
                [[ASDownloadManger sharedInstance] resumeDownload:session.url];
                break;
            default:
                break;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
    
}
//下面是左滑删除的代理
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return   UITableViewCellEditingStyleDelete;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ASSession *session = self.downloadedArr[indexPath.row];
        [self.downloadedArr removeObjectAtIndex:indexPath.row];
        [[ASDownloadManger sharedInstance] deleteDownloadTask:session.url];
    }else {
        ASSession *session = self.downloadingArr[indexPath.row];
        [self.downloadingArr removeObjectAtIndex:indexPath.row];
        [[ASDownloadManger sharedInstance] deleteDownloadTask:session.url];

    }
    [tableView reloadData];

}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
