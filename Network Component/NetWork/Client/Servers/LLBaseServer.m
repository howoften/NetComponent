//
//  LLBaseServer.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLBaseServer.h"

@interface LLBaseServer ()
@property (nonatomic, strong)id<LLBaseServiceProtocol> server;

@property (nonatomic, assign)EnvironmentType environmentType;


@property (nonatomic, strong)NSString *customApiHost;

@end

@implementation LLBaseServer
@synthesize privateKey = _privateKey, hostAddress = _hostAddress;

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(LLBaseServiceProtocol)]) {
            self.server = (id<LLBaseServiceProtocol>)self;
#ifdef WX_BUILD_FOR_RELEASE
            self.environmentType = EnvironmentTypeRelease;
#else
            NSNumber *environmentType = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentType"];
            if (environmentType) {
                self.environmentType = [environmentType integerValue];
            }else {
#ifdef WX_BUILD_FOR_DEV
                self.environmentType = EnvironmentTypeDevelop;
#elif defined WX_BUILD_FOR_TEST
                self.environmentType = EnvironmentTypeTest;
#elif defined WX_BUILD_FOR_PRERELEASE
                self.environmentType = EnvironmentTypePreRelease;
#endif
            }
#endif
        }else {
            NSAssert(NO, @"### A server must conform LLBaseServiceProtocol before it work");

        }
    }
    return self;
}

- (void)setEnvironmentType:(EnvironmentType)environmentType {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:environmentType] forKey:@"environmentType"];
    _environmentType = environmentType;
    _hostAddress = nil;
}

- (NSString *)hostAddress {
    if (!_hostAddress) {
        switch (self.environmentType) {
            case EnvironmentTypeDevelop:
                _hostAddress = self.server.developApiBaseUrl;
                break;
            case EnvironmentTypeTest:
                _hostAddress = self.server.testApiBaseUrl;
                break;
            case EnvironmentTypePreRelease:
                _hostAddress = self.server.prereleaseApiBaseUrl;
                break;
            case EnvironmentTypeRelease:
                _hostAddress = self.server.releaseApiBaseUrl;
                break;
            case EnvironmentTypeCustom:
                _hostAddress = self.server.customApiBaseUrl;
                break;
            default:
                break;
        }
    }
    return _hostAddress;
}

- (NSString *)customApiHost {
    if (!_customApiHost) {
        _customApiHost = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass([self class])];
    }
    return _customApiHost;
}

@end
