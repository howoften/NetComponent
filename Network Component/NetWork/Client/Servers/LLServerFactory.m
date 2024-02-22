//
//  LLServerFactory.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLServerFactory.h"
#import "WXServer.h"

@interface LLServerFactory ()

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, LLBaseServer<LLBaseServiceProtocol> *> *serverStorage;

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
    return [LLServerFactory shareInstance].serverStorage[@(serverType)].environmentType;
}

+ (LLBaseServer<LLBaseServiceProtocol> *)serverWithType:(LLServerType)serverType {
    if (![LLServerFactory shareInstance].serverStorage[@(serverType)]) {
        LLBaseServer<LLBaseServiceProtocol> *newServer = [self newServerWithType:serverType];
        if (newServer) {
            [[LLServerFactory shareInstance].serverStorage setObject:newServer forKey:@(serverType)];
        }
    }
    return [LLServerFactory shareInstance].serverStorage[@(serverType)];
}

+ (LLBaseServer<LLBaseServiceProtocol> *)newServerWithType:(LLServerType)serverType {
    LLBaseServer<LLBaseServiceProtocol> *server = nil;
    switch (serverType) {
        case LLServerWX:
            server = [[WXServer alloc] init];
            break;
            
        default:
            break;
    }
    return server;
}

- (NSMutableDictionary *)serverStorage {
    if (!_serverStorage) {
        _serverStorage = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _serverStorage;
}

@end
