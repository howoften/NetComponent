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

@property (nonatomic, assign)LLEnvironmentType environmentType;
@property (nonatomic, strong)HttpTool *httpTool;

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
            self.httpTool = [[HttpTool alloc] init];
#ifdef LLSERVER_ENV_RELEASE
            self.environmentType = LLEnvironmentTypeRelease;
#else
            NSNumber *environmentType = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentType"];
            if (environmentType) {
                self.environmentType = [environmentType integerValue];
            }else {
#ifdef LLSERVER_ENV_DEV
                self.environmentType = LLEnvironmentTypeDevelop;
#elif defined LLSERVER_ENV_TEST
                self.environmentType = LLEnvironmentTypeTest;
#elif defined LLSERVER_ENV_PRERELEASE
                self.environmentType = LLEnvironmentTypePreRelease;
#endif
            }
#endif
        }else {
            NSAssert(NO, @"### A server must conform LLBaseServiceProtocol before it work");

        }
    }
    return self;
}

- (void)setLLEnvironmentType:(LLEnvironmentType)environmentType {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:environmentType] forKey:@"environmentType"];
    _environmentType = environmentType;
    _hostAddress = nil;
}

- (NSString *)hostAddress {
    if (!_hostAddress) {
        switch (self.environmentType) {
            case LLEnvironmentTypeDevelop:
                _hostAddress = self.server.developApiBaseUrl;
                break;
            case LLEnvironmentTypeTest:
                _hostAddress = self.server.testApiBaseUrl;
                break;
            case LLEnvironmentTypePreRelease:
                _hostAddress = self.server.prereleaseApiBaseUrl;
                break;
            case LLEnvironmentTypeRelease:
                _hostAddress = self.server.releaseApiBaseUrl;
                break;
            case LLEnvironmentTypeCustom:
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

- (NSDictionary *)commonRequestHeaderParametersFor:(LLBaseRequestModel *)requestEntity {
    return nil;
}
- (NSDictionary *)commonRequestParametersFor:(LLBaseRequestModel *)requestEntity {
    return nil;
}

@end
