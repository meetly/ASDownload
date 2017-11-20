//
//  ASListViewController.m
//  DownLoad
//
//  Created by share on 2017/11/16.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASListViewController.h"
#import "ASListTableViewCell.h"
#import "ASDownLoadViewController.h"
#import "ASDownloadManger.h"


@interface ASListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation ASListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点击下载";
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"下载列表" style:(UIBarButtonItemStylePlain) target:self action:@selector(barItemClick)];
    self.navigationItem.rightBarButtonItem=barItem;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, SCREEN_WIDTH, SCREEN_HEIGHT-navHeight)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
}
- (void)barItemClick {
    ASDownLoadViewController *downVC = [[ASDownLoadViewController alloc] init];
    [self.navigationController pushViewController:downVC animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ASListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.nameLabel.text = self.sourceArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [[ASDownloadManger sharedInstance] setMaximumConnection:1];
    ASDownloadTaskState state = [[ASDownloadManger sharedInstance] download:self.sourceArr[indexPath.row] progress:nil state:nil];
    switch (state) {
        case ASDownloadTaskStateUrlNil:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载地址错误" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
            break;
        case ASDownloadTaskStateUrlRrror:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载地址错误" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
            break;
        case ASDownloadTaskStateCompleted:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"此任务已下载完成" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
            break;
        case ASDownloadTaskStateCanDownload:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加到下载列表" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
            break;
            
        default:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"列表中已有该任务" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSMutableArray *)sourceArr {
    if (!_sourceArr) {
        _sourceArr = @[
                       @"https://cdn.shihua.com/videos/%E9%A2%86%E5%AF%BC%E6%97%A0%E5%BD%A2%E7%AE%A1%E7%90%86%E6%9C%89%E9%81%93/39.%E5%BB%BA%E7%AB%8B%E4%BC%A0%E5%B8%AE%E5%B8%A6%E6%9C%BA%E5%88%B6%E4%B8%8E%E9%A3%8E%E6%B0%94.mp4",
                       @"http://221.228.226.8/13/k/k/y/a/kkyagaptwldwbsuyricmrcnnvdgrvr/sh.yinyuetai.com/1F7D015F8F1D8A4277F8260691A5D80F.mp4",
                       @"http://113.105.248.47/7/k/q/c/h/kqchypojfvorzsswimdqqzkelhnpit/sh.yinyuetai.com/2C3E015F0AF6935955FC8F573886BF91.mp4",
                       @"http://221.228.226.5/18/j/a/g/x/jagxjnrhqynrheczhjraumrshtrbny/he.yinyuetai.com/ED38015F6125DBBD5FA0FCF46227DBA0.mp4",
                       @"http://113.105.248.47/7/f/t/b/d/ftbdorjlxonsomhzbdeagxbdiejoxn/sh.yinyuetai.com/DF96015F37841A8D6CA34A7EA49909EB.mp4",
                       @"http://220.170.49.114/1/t/p/s/x/tpsxggfrlfpatvpfvtaaoltgnpgiib/sh.yinyuetai.com/C0DE015EB74040A13C3BC5756AD1086B.mp4",
                       @"http://183.60.197.26/7/y/j/t/f/yjtfwhmpiwmakuwpudcbnlcskeqzic/hd.yinyuetai.com/3CDD015EA41F2043C31390354BC1DE51.mp4"].mutableCopy;
    }
    return _sourceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
