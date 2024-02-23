//
//  ServerConfig.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#ifndef ServerConfig_h
#define ServerConfig_h

#define Response_Success_Code 200

#if !defined WX_BUILD_FOR_DEV && !defined WX_BUILD_FOR_TEST && !defined WX_BUILD_FOR_RELEASE && !defined WX_BUILD_FOR_PRERELEASE

//#define WX_BUILD_FOR_DEV
#define WX_BUILD_FOR_TEST
//#define WX_BUILD_FOR_RELEASE
//#define WX_BUILD_FOR_PRERELEASE

#endif

/**
 *  开发、测试、预发、正式环境, 自定的切换是给开发人员和测试人员用的，对于外部正式打包不应该有环境切换的存在
 */
typedef NS_ENUM(NSUInteger, EnvironmentType) {
    EnvironmentTypeDevelop,
    EnvironmentTypeTest,
    EnvironmentTypePreRelease,
    EnvironmentTypeRelease,
    EnvironmentTypeCustom,
    
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
