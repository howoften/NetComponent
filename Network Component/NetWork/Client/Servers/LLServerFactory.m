//
//  LLServerFactory.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLServerFactory.h"
#import "WXServer.h"
#import "AppleServer.h"
#import "GreenCloudServer.h"

@interface LLServerFactory ()

@end

@implementation LLServerFactory

+ (instancetype)shareInstance {
    static LLServerFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[LLServerFactory alloc] init];
    });
    return factory;
}

+ (EnvironmentType)environmentTypeOfServer:(LLServerType)serverType {
    return [self serverWithType:serverType].environmentType;
}

+ (LLBaseServer<LLBaseServiceProtocol> *)serverWithType:(LLServerType)serverType {
    LLBaseServer<LLBaseServiceProtocol> *server = nil;
    switch (serverType) {
        case LLServerWX:
            server = [WXServer sharedInstance];
            break;
        case LLServerApple:
            server = [AppleServer sharedInstance];
            break;
        case LLServerGreenCloud:
            server = [GreenCloudServer sharedInstance];
            break;
        default:
            break;
    }
    return server;
}

@end
