//
//  WXServer.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "WXServer.h"

NSString * const LoginTokenKey = @"LoginTokenKey";

@implementation WXServer

@synthesize developApiBaseUrl = _developApiBaseUrl, testApiBaseUrl = _testApiBaseUrl, prereleaseApiBaseUrl = _prereleaseApiBaseUrl, releaseApiBaseUrl = _releaseApiBaseUrl, customApiBaseUrl = _customApiBaseUrl;

- (NSString *)developApiBaseUrl {
    if (!_developApiBaseUrl) {
        _developApiBaseUrl = @"https://wuxi.test.brightcns.cn";
    }
    return _developApiBaseUrl;
}
- (NSString *)testApiBaseUrl {
    if (!_testApiBaseUrl) {
        _testApiBaseUrl = @"https://wuxi.test.brightcns.cn";
    }
    return _testApiBaseUrl;
}

- (NSString *)prereleaseApiBaseUrl {
    if (!_prereleaseApiBaseUrl) {
        _prereleaseApiBaseUrl = @"https://wuxi.test.brightcns.cn";
    }
    return _prereleaseApiBaseUrl;
}

- (NSString *)releaseApiBaseUrl {
    if (!_releaseApiBaseUrl) {
        _releaseApiBaseUrl = @"https://wuxi.test.brightcns.cn";
    }
    return _releaseApiBaseUrl;
}

- (NSString *)customApiBaseUrl {
    if (!_customApiBaseUrl) {
        _customApiBaseUrl = @"WXCitizenCard";
    }
    return _customApiBaseUrl;
}

- (NSDictionary *)signTokenInfo {
   return @{
      LoginTokenKey:@"",
      
      };
}

@end
