//
//  ASDownloadTableViewCell.m
//  DownLoad
//
//  Created by share on 2017/11/16.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASDownloadTableViewCell.h"

@implementation ASDownloadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.sizeLabel];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.speedLabel];
        [self.contentView addSubview:self.stateLabbel];
    }
    return self;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.contentView.center.y-25, self.frame.size.width - 10, 50)];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 2;
    }
    return _nameLabel;
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 50, self.frame.size.width - 40, 10)];
        _progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:166/255.0 blue:277/255.0 alpha:1];
        _progressView.trackTintColor = [UIColor lightGrayColor];
    }
    return  _progressView;
}
- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, 60,  150, 20)];
        _sizeLabel.font = [UIFont systemFontOfSize:15];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.textColor = [UIColor colorWithRed:62/255.0 green:166/255.0 blue:277/255.0 alpha:1];
    }
    return _sizeLabel;
}
- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60,  100, 20)];
        _speedLabel.font = [UIFont systemFontOfSize:15];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        _speedLabel.textColor = [UIColor colorWithRed:62/255.0 green:166/255.0 blue:277/255.0 alpha:1];
    }
    return _speedLabel;
}
- (UILabel *)stateLabbel {
    if (!_stateLabbel) {
        _stateLabbel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 40, 70, 20)];
        _stateLabbel.font = [UIFont systemFontOfSize:15];
        _stateLabbel.textAlignment = NSTextAlignmentCenter;
        _stateLabbel.textColor = [UIColor colorWithRed:62/255.0 green:166/255.0 blue:277/255.0 alpha:1];
    }
    return _stateLabbel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
