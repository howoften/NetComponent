//
//  LLAppContext.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+UUID.h"

@interface LLAppContext : NSObject

@property (nonatomic, copy, readonly) NSString *channelID;    //渠道号
@property (nonatomic, copy, readonly) NSString *app_client_id;         //请求来源，值都是@"mobile"
@property (nonatomic, copy, readonly) NSString *appName;      //应用名称
@property (nonatomic, copy, readonly) NSString *device_name;            //设备名称
@property (nonatomic, copy, readonly) NSString *os_name;            //系统名称
@property (nonatomic, copy, readonly) NSString *os_version;            //系统版本
@property (nonatomic, copy, readonly) NSString *build_version;           //Bundle版本
@property (nonatomic, copy, readonly) NSString *bundle_id;           //应用 标识
@property (nonatomic, copy, readonly) NSString *app_version;           //app版本
@property (nonatomic, copy, readonly) NSString *device_model;      //设备型号
@property (nonatomic, copy, readonly) NSString *qtime;        //发送请求的时间
@property (nonatomic, copy, readonly) NSString *device_id;

@end
