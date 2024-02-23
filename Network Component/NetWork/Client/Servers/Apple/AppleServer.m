//
//  AppleServer.m
//  SJTransport
//
//  Created by 刘江 on 2018/8/27.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "AppleServer.h"

@implementation AppleServer

@synthesize developApiBaseUrl = _developApiBaseUrl, testApiBaseUrl = _testApiBaseUrl, prereleaseApiBaseUrl = _prereleaseApiBaseUrl, releaseApiBaseUrl = _releaseApiBaseUrl, customApiBaseUrl = _customApiBaseUrl;

+ (id<LLBaseServiceProtocol>)sharedInstance {
    static AppleServer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AppleServer alloc] init];
    });
    return shared;
}

- (NSString *)developApiBaseUrl {
    if (!_developApiBaseUrl) {
        _developApiBaseUrl = @"https://itunes.apple.com";
    }
    return _developApiBaseUrl;
}

- (NSString *)testApiBaseUrl {
    if (!_testApiBaseUrl) {
        _testApiBaseUrl = @"https://itunes.apple.com";
    }
    return _testApiBaseUrl;
}

- (NSString *)prereleaseApiBaseUrl {
    if (!_prereleaseApiBaseUrl) {
        _prereleaseApiBaseUrl = @"https://itunes.apple.com";
    }
    return _prereleaseApiBaseUrl;
}

- (NSString *)releaseApiBaseUrl {
    if (!_releaseApiBaseUrl) {
        _releaseApiBaseUrl = @"https://itunes.apple.com";
    }
    return _releaseApiBaseUrl;
}
@end
