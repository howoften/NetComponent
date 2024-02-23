//
//  LLBaseServer.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConfig.h"

@protocol LLBaseServiceProtocol <NSObject>
/**
 *  开发、测试、预发、正式、自定, 五种环境的baseUrl在子类中实现，获取对应的URL赋值给apiBaseUrl，自定义在基类中进行保存获取
 */
@property (nonatomic, class, readonly) id<LLBaseServiceProtocol> sharedInstance;
@property (nonatomic, strong, readonly) NSString *developApiBaseUrl;
@property (nonatomic, strong, readonly) NSString *testApiBaseUrl;
@property (nonatomic, strong, readonly) NSString *prereleaseApiBaseUrl;
@property (nonatomic, strong, readonly) NSString *releaseApiBaseUrl;
@property (nonatomic, strong, readonly) NSString *customApiBaseUrl;

@end

@interface LLBaseServer : NSObject

@property (nonatomic, assign, readonly)EnvironmentType environmentType;

@property (nonatomic, strong, readonly)NSString *privateKey;
@property (nonatomic, strong, readonly)NSString *publicKey;
@property (nonatomic, strong, readonly)NSString *hostAddress;

@property (nonatomic, strong)NSDictionary *signTokenInfo;

@end
