//
//  ASDownloadTableViewCell.h
//  DownLoad
//
//  Created by share on 2017/11/16.
//  Copyright © 2017年 share. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASDownloadTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *stateLabbel;
@end
