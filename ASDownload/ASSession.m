//
//  ASSession.m
//  DownLoad
//
//  Created by share on 2017/11/13.
//  Copyright © 2017年 share. All rights reserved.
//

#import "ASSession.h"

@implementation ASSession

static NSString *url = @"url";
static NSString *startTime = @"startTime";
static NSString *fileName = @"fileName";
static NSString *totalSize = @"totalSize";
static NSString *totalLength = @"totalLength";
static NSString *totalBytesWritten = @"totalBytesWritten";
static NSString *progress = @"progress";
static NSString *downloadState = @"downloadState";

- (void)encodeWithCoder:(NSCoder *)aCoder //将属性进行编码
{
    [aCoder encodeObject:self.url forKey:url];
    [aCoder encodeObject:self.startTime forKey:startTime];
    [aCoder encodeObject:self.fileName forKey:fileName];
    [aCoder encodeObject:self.totalSize forKey:totalSize];
    [aCoder encodeInteger:self.totalLength forKey:totalLength];
    [aCoder encodeObject:self.totalBytesWritten forKey:totalBytesWritten];
    [aCoder encodeFloat:self.progress forKey:progress];
    [aCoder encodeInteger:self.downloadState forKey:downloadState];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder //将属性进行解码
{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:url];
        self.startTime = [aDecoder decodeObjectForKey:startTime];
        self.fileName = [aDecoder decodeObjectForKey:fileName];
        self.totalSize = [aDecoder decodeObjectForKey:totalSize];
        self.totalLength = [aDecoder decodeIntegerForKey:totalLength];
        self.totalBytesWritten = [aDecoder decodeObjectForKey:totalBytesWritten];
        self.progress = [aDecoder decodeFloatForKey:progress];
        self.downloadState = [aDecoder decodeIntegerForKey:downloadState];
    }
    return self;
}
@end
