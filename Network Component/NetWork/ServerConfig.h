//
//  ServerConfig.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#ifndef ServerConfig_h
#define ServerConfig_h

#define Response_Success_Code(code) (code*(code - 200) == 0)

#if !defined LLSERVER_ENV_DEV && !defined LLSERVER_ENV_TEST && !defined LLSERVER_ENV_RELEASE && !defined LLSERVER_ENV_PRERELEASE

//#define LLSERVER_ENV_DEV
#define LLSERVER_ENV_TEST
//#define LLSERVER_ENV_RELEASE
//#define LLSERVER_ENV_PRERELEASE

#endif

/**
 *  开发、测试、预发、正式环境, 自定的切换是给开发人员和测试人员用的，对于外部正式打包不应该有环境切换的存在
 */
typedef NS_ENUM(NSUInteger, LLEnvironmentType) {
    LLEnvironmentTypeDevelop,
    LLEnvironmentTypeTest,
    LLEnvironmentTypePreRelease,
    LLEnvironmentTypeRelease,
    LLEnvironmentTypeCustom,
    
};

typedef NS_ENUM(NSUInteger, LLServerType) {
    LLServerWX,
    LLServerApple,
    LLServerGreenCloud
};

typedef NS_ENUM(NSUInteger, LLAPIRequestType) {
     LLAPIRequestTypeGet,
     LLAPIRequestTypePost,
     LLAPIRequestTypePostForm,
     LLAPIRequestTypePut,
     LLAPIRequestTypeDelete,
     LLAPIRequestTypeUpload
};

extern NSString * const LoginTokenKey;


#endif /* ServerConfig_h */
