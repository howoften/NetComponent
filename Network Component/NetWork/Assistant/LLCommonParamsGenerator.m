//
//  LLCommonParamsGenerator.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLCommonParamsGenerator.h"
#import "LLAppContext.h"
#import <UIKit/UIKit.h>
@implementation LLCommonParamsGenerator

+ (NSDictionary *)commonRequestHeaderParams {
    LLAppContext *appContext = [[LLAppContext alloc] init];
    NSDictionary *commonParam = @{@"User-Agent":[self userAgent]};
    
    return commonParam;
}

+ (NSDictionary *)commonRequestParameters {
    LLAppContext *appContext = [[LLAppContext alloc] init];
    NSDictionary *commonParam = @{};
    
    return commonParam;
}

+ (NSString *)userAgent {
    LLAppContext *app = [[LLAppContext alloc] init];
    
    NSString *bunldId = app.bundle_id;
    NSString *appVersion = [@"V" stringByAppendingString:app.app_version];
    NSString *osKern = @"Unix";
    NSString *systemVersion = [[[[UIDevice currentDevice] systemName] stringByAppendingString:@" "] stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *deviceModel = app.device_model;
    NSString *brand_Model = [@"Build/Apple-" stringByAppendingString:deviceModel];
    NSString *buildVersion = [@"BuildCode/" stringByAppendingString:app.build_version];
    
    NSString *user_agent = [[[[[[[[[[[[[[[bunldId stringByAppendingString:@"/"] stringByAppendingString:appVersion] stringByAppendingString:@" ("] stringByAppendingString:osKern] stringByAppendingString:@"; "] stringByAppendingString:systemVersion] stringByAppendingString:@"; "] stringByAppendingString:language] stringByAppendingString:@"; "] stringByAppendingString:deviceModel] stringByAppendingString:@" "] stringByAppendingString:brand_Model] stringByAppendingString:@" "] stringByAppendingString:buildVersion] stringByAppendingString:@")"];
    
    return user_agent;
}

@end
