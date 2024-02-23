//
//  AppleServer.m
//  SJTransport
//
//  Created by 刘江 on 2018/8/27.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "GreenCloudServer.h"

@implementation GreenCloudServer

@synthesize developApiBaseUrl = _developApiBaseUrl, testApiBaseUrl = _testApiBaseUrl, prereleaseApiBaseUrl = _prereleaseApiBaseUrl, releaseApiBaseUrl = _releaseApiBaseUrl, customApiBaseUrl = _customApiBaseUrl;
+ (id<LLBaseServiceProtocol>)sharedInstance {
    static GreenCloudServer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GreenCloudServer alloc] init];
    });
    return shared;
}

- (NSString *)developApiBaseUrl {
    if (!_developApiBaseUrl) {
        _developApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _developApiBaseUrl;
}

- (NSString *)testApiBaseUrl {
    if (!_testApiBaseUrl) {
        _testApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _testApiBaseUrl;
}

- (NSString *)prereleaseApiBaseUrl {
    if (!_prereleaseApiBaseUrl) {
        _prereleaseApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _prereleaseApiBaseUrl;
}

- (NSString *)releaseApiBaseUrl {
    if (!_releaseApiBaseUrl) {
        _releaseApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _releaseApiBaseUrl;
}
@end
