//
//  ASListTableViewCell.m
//  DownLoad
//
//  Created by share on 2017/11/16.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASListTableViewCell.h"

@implementation ASListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.loadLabel];
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
- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width, self.contentView.center.y-10,  50, 20)];
        _loadLabel.font = [UIFont systemFontOfSize:15];
        _loadLabel.textAlignment = NSTextAlignmentCenter;
        _loadLabel.textColor = [UIColor colorWithRed:62/255.0 green:166/255.0 blue:277/255.0 alpha:1];
        _loadLabel.text = @"下载";
    }
    return _loadLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
