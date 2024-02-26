//
//  LLServerFactory.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConfig.h"
#import "LLBaseServer.h"

@interface LLServerFactory : NSObject

+ (LLEnvironmentType)environmentTypeOfServer:(LLServerType)serverType;

+ (LLBaseServer<LLBaseServiceProtocol> *)serverWithType:(LLServerType)serverType;

@end
